import asyncio
import os
from typing import Any

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

app = FastAPI(title="Movana Preview API")

TMDB_BASE_URL = "https://api.themoviedb.org/3"
TMDB_IMAGE_BASE = "https://image.tmdb.org/t/p"
TMDB_TOKEN = os.environ.get("TMDB_ACCESS_TOKEN")
REGION = "IN"
LANGUAGE = "en-IN"

MOVIE_CATEGORIES = {
    "trending": "/trending/movie/day",
    "popular": "/movie/popular",
    "top_rated": "/movie/top_rated",
    "now_playing": "/movie/now_playing",
    "upcoming": "/movie/upcoming",
}

TV_CATEGORIES = {
    "trending": "/trending/tv/day",
    "popular": "/tv/popular",
    "top_rated": "/tv/top_rated",
    "now_playing": "/tv/on_the_air",
    "upcoming": "/tv/airing_today",
}

DESIRED_PROVIDERS = [
    "Netflix",
    "Amazon Prime Video",
    "Disney+ Hotstar",
    "JioHotstar",
    "Sony Liv",
    "ZEE5",
    "Apple TV+",
    "MX Player",
    "aha",
    "Sun Nxt",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health():
    return {"status": "ok", "app": "Movana", "mode": "preview"}


@app.get("/api")
def root():
    return {"message": "Movana preview API is running"}


def _headers() -> dict[str, str]:
    if not TMDB_TOKEN:
        raise HTTPException(status_code=500, detail="TMDB token is not configured on the server")
    return {"Authorization": f"Bearer {TMDB_TOKEN}", "accept": "application/json"}


async def tmdb_get(path: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
    safe_params = {"language": LANGUAGE, "region": REGION, **(params or {})}
    async with httpx.AsyncClient(base_url=TMDB_BASE_URL, timeout=15) as client:
        response = await client.get(path, params=safe_params, headers=_headers())
    if response.status_code >= 400:
        raise HTTPException(status_code=response.status_code, detail="TMDB request failed")
    return response.json()


async def hydrate_list_items(items: list[dict[str, Any]], content_type: str) -> list[dict[str, Any]]:
    async def hydrate(item: dict[str, Any]) -> dict[str, Any]:
        item_id = item.get("id")
        if not item_id:
            return item
        try:
            detail = await tmdb_get(f"/{content_type}/{item_id}", {"append_to_response": "watch/providers"})
            return {**item, **detail, "media_type": content_type}
        except Exception:
            return item

    return await asyncio.gather(*(hydrate(item) for item in items[:20]))


def image_url(path: str | None, size: str) -> str:
    return f"{TMDB_IMAGE_BASE}/{size}{path}" if path else ""


def year_from(date_value: str | None) -> int:
    if not date_value:
        return 0
    try:
        return int(date_value[:4])
    except ValueError:
        return 0


def certification_from(release_dates: dict[str, Any]) -> str:
    for country in release_dates.get("results", []):
        if country.get("iso_3166_1") == REGION:
            for release in country.get("release_dates", []):
                cert = release.get("certification")
                if cert:
                    return cert
    return "NR"


def providers_from(watch_providers: dict[str, Any]) -> list[str]:
    region_data = watch_providers.get("results", {}).get(REGION, {})
    providers: list[str] = []
    for bucket in ["flatrate", "free", "ads", "rent", "buy"]:
        for provider in region_data.get(bucket, []) or []:
            name = provider.get("provider_name")
            if name and name not in providers:
                providers.append(name)
    return providers


def trailer_from(videos: dict[str, Any]) -> str:
    for video in videos.get("results", []) or []:
        if video.get("site") == "YouTube" and video.get("type") == "Trailer":
            return f"https://www.youtube.com/watch?v={video.get('key')}"
    return ""


def cast_from(credits: dict[str, Any], limit: int = 5) -> str:
    names = [person.get("name") for person in credits.get("cast", [])[:limit] if person.get("name")]
    return ", ".join(names)


def director_from(credits: dict[str, Any]) -> str:
    for person in credits.get("crew", []) or []:
        if person.get("job") == "Director":
            return person.get("name", "Unknown")
    return "Unknown"


def normalize_movie(
    item: dict[str, Any],
    genres_by_id: dict[int, str] | None = None,
    detail: dict[str, Any] | None = None,
    content_type: str | None = None,
) -> dict[str, Any]:
    source = detail or item
    media_type = content_type or source.get("media_type") or ("series" if source.get("name") else "movie")
    genre_names = [genre.get("name") for genre in source.get("genres", []) if genre.get("name")]
    if not genre_names and genres_by_id:
        genre_names = [genres_by_id.get(genre_id) for genre_id in item.get("genre_ids", []) if genres_by_id.get(genre_id)]
    release_date = source.get("release_date") or item.get("release_date") or source.get("first_air_date") or item.get("first_air_date")
    return {
        "id": str(source.get("id") or item.get("id")),
        "tmdbId": source.get("id") or item.get("id"),
        "title": source.get("title") or item.get("title") or source.get("name") or item.get("name") or "Untitled",
        "year": year_from(release_date),
        "rating": round(float(source.get("vote_average") or item.get("vote_average") or 0), 1),
        "votes": int(source.get("vote_count") or item.get("vote_count") or 0),
        "genres": genre_names,
        "runtime": int(source.get("runtime") or (source.get("episode_run_time") or [0])[0] or 0),
        "language": (source.get("original_language") or item.get("original_language") or "").upper(),
        "providers": providers_from(source.get("watch/providers", {})),
        "age": certification_from(source.get("release_dates", {})) if detail else "NR",
        "type": "Series" if media_type in ["tv", "series"] else "Movie",
        "director": director_from(source.get("credits", {})) if detail else "View details",
        "cast": cast_from(source.get("credits", {})) if detail else "View details for cast",
        "poster": image_url(source.get("poster_path") or item.get("poster_path"), "w500"),
        "backdrop": image_url(source.get("backdrop_path") or item.get("backdrop_path"), "w1280"),
        "overview": source.get("overview") or item.get("overview") or "Overview not available.",
        "trailer": trailer_from(source.get("videos", {})) if detail else "",
    }


@app.get("/api/tmdb/home")
async def tmdb_home(page: int = Query(default=1, ge=1, le=20)):
    genres_response = await tmdb_get("/genre/movie/list")
    genres_by_id = {genre["id"]: genre["name"] for genre in genres_response.get("genres", [])}
    payload: dict[str, Any] = {"categories": {}, "genres": list(genres_by_id.values())}
    for key, path in MOVIE_CATEGORIES.items():
        data = await tmdb_get(path, {"page": page})
        payload["categories"][key] = [normalize_movie(item, genres_by_id) for item in data.get("results", []) if item.get("poster_path")]
    return payload


@app.get("/api/tmdb/providers")
async def tmdb_providers():
    movie_providers = await tmdb_get("/watch/providers/movie", {"watch_region": REGION})
    tv_providers = await tmdb_get("/watch/providers/tv", {"watch_region": REGION})
    by_name: dict[str, dict[str, Any]] = {}
    for provider in (movie_providers.get("results", []) + tv_providers.get("results", [])):
        name = provider.get("provider_name")
        if name and name not in by_name:
            by_name[name] = provider
    output = []
    for desired in DESIRED_PROVIDERS:
        match = by_name.get(desired) or next((p for name, p in by_name.items() if desired.lower() in name.lower() or name.lower() in desired.lower()), None)
        if match:
            output.append({
                "id": match.get("provider_id"),
                "name": desired,
                "tmdbName": match.get("provider_name"),
                "logo": image_url(match.get("logo_path"), "w300"),
            })
    return {"providers": output}


@app.get("/api/tmdb/genres")
async def tmdb_genres(content_type: str = Query(default="movie", pattern="^(movie|tv)$")):
    genres_response = await tmdb_get(f"/genre/{content_type}/list")
    async def genre_card(genre: dict[str, Any]) -> dict[str, Any]:
        discover_path = f"/discover/{content_type}"
        date_field = "primary_release_date.lte" if content_type == "movie" else "first_air_date.lte"
        data = await tmdb_get(discover_path, {
            "with_genres": genre["id"],
            "sort_by": "vote_average.desc",
            "vote_count.gte": 500,
            date_field: "2099-12-31",
            "page": 1,
        })
        poster_item = next((item for item in data.get("results", []) if item.get("poster_path") or item.get("backdrop_path")), {})
        return {
            "id": genre["id"],
            "name": genre["name"],
            "poster": image_url(poster_item.get("poster_path"), "w500"),
            "backdrop": image_url(poster_item.get("backdrop_path"), "w780"),
        }

    results = await asyncio.gather(*(genre_card(genre) for genre in genres_response.get("genres", [])))
    return {"genres": results}


@app.get("/api/tmdb/discover")
async def tmdb_discover(
    content_type: str = Query(default="movie", pattern="^(movie|tv)$"),
    genre_id: int | None = None,
    provider_id: int | None = None,
    rating: str = "top",
    time: str = "all",
    page: int = Query(default=1, ge=1, le=20),
):
    path = f"/discover/{content_type}"
    params: dict[str, Any] = {
        "page": page,
        "with_genres": genre_id,
        "watch_region": REGION,
        "with_watch_providers": provider_id,
        "sort_by": "vote_average.desc",
        "vote_count.gte": 250,
    }
    rating_ranges = {
        "8_10": (8, 10),
        "6_8": (6, 8),
        "4_6": (4, 6),
        "1_4": (1, 4),
    }
    if rating in rating_ranges:
        params["vote_average.gte"], params["vote_average.lte"] = rating_ranges[rating]
    if time == "latest":
        params["sort_by"] = "primary_release_date.desc" if content_type == "movie" else "first_air_date.desc"
    elif time == "oldest":
        params["sort_by"] = "primary_release_date.asc" if content_type == "movie" else "first_air_date.asc"
    data = await tmdb_get(path, {key: value for key, value in params.items() if value is not None})
    raw_items = [item for item in data.get("results", []) if item.get("poster_path")]
    hydrated = await hydrate_list_items(raw_items, content_type)
    return {"results": [normalize_movie(item, detail=item, content_type=content_type) for item in hydrated]}


@app.get("/api/tmdb/search")
async def tmdb_search(q: str = Query(default="", min_length=0), page: int = Query(default=1, ge=1, le=20)):
    if not q.strip():
        return {"results": []}
    genres_response = await tmdb_get("/genre/movie/list")
    genres_by_id = {genre["id"]: genre["name"] for genre in genres_response.get("genres", [])}
    data = await tmdb_get("/search/multi", {"query": q.strip(), "page": page, "include_adult": "false"})
    results = []
    for item in data.get("results", []):
        media_type = item.get("media_type")
        if media_type in ["movie", "tv"] and item.get("poster_path"):
            results.append(normalize_movie(item, genres_by_id, content_type=media_type))
        elif media_type == "person":
            for known in item.get("known_for", []) or []:
                if known.get("media_type") in ["movie", "tv"] and known.get("poster_path"):
                    results.append(normalize_movie(known, genres_by_id, content_type=known.get("media_type")))
    return {"results": results}


@app.get("/api/tmdb/movie/{movie_id}")
async def tmdb_movie_details(movie_id: int):
    detail = await tmdb_get(
        f"/movie/{movie_id}",
        {"append_to_response": "credits,videos,watch/providers,release_dates,recommendations"},
    )
    movie = normalize_movie(detail, detail=detail)
    recommendations = [
        normalize_movie(item)
        for item in detail.get("recommendations", {}).get("results", [])[:6]
        if item.get("poster_path")
    ]
    movie["recommendations"] = recommendations
    return movie
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

CATEGORIES = {
    "trending": "/trending/movie/day",
    "popular": "/movie/popular",
    "top_rated": "/movie/top_rated",
    "now_playing": "/movie/now_playing",
    "upcoming": "/movie/upcoming",
}

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


def normalize_movie(item: dict[str, Any], genres_by_id: dict[int, str] | None = None, detail: dict[str, Any] | None = None) -> dict[str, Any]:
    source = detail or item
    genre_names = [genre.get("name") for genre in source.get("genres", []) if genre.get("name")]
    if not genre_names and genres_by_id:
        genre_names = [genres_by_id.get(genre_id) for genre_id in item.get("genre_ids", []) if genres_by_id.get(genre_id)]
    release_date = source.get("release_date") or item.get("release_date")
    return {
        "id": str(source.get("id") or item.get("id")),
        "tmdbId": source.get("id") or item.get("id"),
        "title": source.get("title") or item.get("title") or "Untitled",
        "year": year_from(release_date),
        "rating": round(float(source.get("vote_average") or item.get("vote_average") or 0), 1),
        "votes": int(source.get("vote_count") or item.get("vote_count") or 0),
        "genres": genre_names,
        "runtime": int(source.get("runtime") or 0),
        "language": (source.get("original_language") or item.get("original_language") or "").upper(),
        "providers": providers_from(source.get("watch/providers", {})),
        "age": certification_from(source.get("release_dates", {})) if detail else "NR",
        "type": "Movie",
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
    for key, path in CATEGORIES.items():
        data = await tmdb_get(path, {"page": page})
        payload["categories"][key] = [normalize_movie(item, genres_by_id) for item in data.get("results", []) if item.get("poster_path")]
    return payload


@app.get("/api/tmdb/search")
async def tmdb_search(q: str = Query(default="", min_length=0), page: int = Query(default=1, ge=1, le=20)):
    if not q.strip():
        return {"results": []}
    genres_response = await tmdb_get("/genre/movie/list")
    genres_by_id = {genre["id"]: genre["name"] for genre in genres_response.get("genres", [])}
    data = await tmdb_get("/search/movie", {"query": q.strip(), "page": page, "include_adult": "false"})
    return {"results": [normalize_movie(item, genres_by_id) for item in data.get("results", []) if item.get("poster_path")]}


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
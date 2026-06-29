import os

import pytest
import requests


BASE_URL = os.environ.get("REACT_APP_BACKEND_URL")


@pytest.fixture(scope="session")
def api_base() -> str:
    if not BASE_URL:
        pytest.skip("REACT_APP_BACKEND_URL is not configured")
    return BASE_URL.rstrip("/")


@pytest.fixture(scope="session")
def api_client():
    session = requests.Session()
    session.headers.update({"Content-Type": "application/json"})
    return session


class TestPreviewFlow:
    """TMDB-backed preview APIs for redesigned OTT -> genres -> discover flow."""

    def test_health(self, api_client, api_base):
        response = api_client.get(f"{api_base}/api/health", timeout=30)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["app"] == "Movana"

    def test_providers(self, api_client, api_base):
        response = api_client.get(f"{api_base}/api/tmdb/providers", timeout=60)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data.get("providers"), list)
        assert len(data["providers"]) > 0

        first = data["providers"][0]
        assert isinstance(first.get("id"), int)
        assert isinstance(first.get("name"), str)
        assert isinstance(first.get("logo"), str)

    def test_genres_movie(self, api_client, api_base):
        response = api_client.get(f"{api_base}/api/tmdb/genres", params={"content_type": "movie"}, timeout=120)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data.get("genres"), list)
        assert len(data["genres"]) > 0

        first = data["genres"][0]
        assert isinstance(first.get("id"), int)
        assert isinstance(first.get("name"), str)
        assert "poster" in first
        assert "backdrop" in first

    def test_discover_movie_top_all(self, api_client, api_base):
        providers = api_client.get(f"{api_base}/api/tmdb/providers", timeout=60).json().get("providers", [])
        genres = api_client.get(
            f"{api_base}/api/tmdb/genres", params={"content_type": "movie"}, timeout=120
        ).json().get("genres", [])

        assert len(providers) > 0
        assert len(genres) > 0

        response = api_client.get(
            f"{api_base}/api/tmdb/discover",
            params={
                "content_type": "movie",
                "provider_id": providers[0]["id"],
                "genre_id": genres[0]["id"],
                "rating": "top",
                "time": "all",
            },
            timeout=120,
        )
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data.get("results"), list)

        if data["results"]:
            first = data["results"][0]
            assert isinstance(first.get("title"), str)
            assert isinstance(first.get("rating"), float)
            assert isinstance(first.get("year"), int)
            assert isinstance(first.get("runtime"), int)
            assert isinstance(first.get("overview"), str)
            assert isinstance(first.get("poster"), str)

    def test_search(self, api_client, api_base):
        response = api_client.get(f"{api_base}/api/tmdb/search", params={"q": "nolan"}, timeout=90)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data.get("results"), list)

    def test_invalid_genres_content_type(self, api_client, api_base):
        response = api_client.get(f"{api_base}/api/tmdb/genres", params={"content_type": "invalid"}, timeout=30)
        assert response.status_code == 422

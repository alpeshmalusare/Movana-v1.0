import React, { useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Heart, Home, Search, Star, Theater, UserRound, Shield, Bell, BarChart3, Share2, PlayCircle, CheckCircle2 } from 'lucide-react';
import './styles.css';

const logo = '/assets/images/movana_logo.png';
const icon = '/assets/images/movana_icon.png';

const platforms = ['Netflix', 'Amazon Prime Video', 'JioHotstar', 'Sony LIV', 'ZEE5', 'Apple TV+', 'JioCinema', 'MX Player', 'Lionsgate Play', 'Crunchyroll', 'MUBI'];
const fallbackGenres = ['Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family', 'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Science Fiction', 'Thriller', 'War', 'Western'];
const categoryLabels = { trending: 'Trending', popular: 'Popular', top_rated: 'Top Rated', now_playing: 'Now Playing', upcoming: 'Upcoming' };

function App() {
  const [boot, setBoot] = useState(true);
  const [authed, setAuthed] = useState(false);
  const [tab, setTab] = useState('home');
  const [query, setQuery] = useState('');
  const [selectedPlatforms, setSelectedPlatforms] = useState([]);
  const [selectedGenres, setSelectedGenres] = useState([]);
  const [contentType, setContentType] = useState('All');
  const [watchlist, setWatchlist] = useState([]);
  const [watched, setWatched] = useState([]);
  const [detail, setDetail] = useState(null);
  const [catalog, setCatalog] = useState({ categories: {}, genres: fallbackGenres });
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState('');

  React.useEffect(() => { const timer = setTimeout(() => setBoot(false), 1400); return () => clearTimeout(timer); }, []);

  React.useEffect(() => {
    let alive = true;
    setLoading(true);
    fetch('/api/tmdb/home')
      .then((res) => res.ok ? res.json() : Promise.reject(new Error('Unable to load TMDB movies')))
      .then((data) => { if (alive) { setCatalog(data); setError(''); } })
      .catch((err) => { if (alive) setError(err.message || 'Unable to load live TMDB data'); })
      .finally(() => { if (alive) setLoading(false); });
    return () => { alive = false; };
  }, []);

  React.useEffect(() => {
    const q = query.trim();
    if (!q) { setSearchResults([]); setSearching(false); return; }
    const controller = new AbortController();
    const timer = setTimeout(() => {
      setSearching(true);
      fetch(`/api/tmdb/search?q=${encodeURIComponent(q)}`, { signal: controller.signal })
        .then((res) => res.ok ? res.json() : Promise.reject(new Error('Search failed')))
        .then((data) => setSearchResults(data.results || []))
        .catch((err) => { if (err.name !== 'AbortError') setError('Search failed. Please try again.'); })
        .finally(() => setSearching(false));
    }, 300);
    return () => { clearTimeout(timer); controller.abort(); };
  }, [query]);

  const liveMovies = useMemo(() => {
    const source = query.trim() ? searchResults : Object.values(catalog.categories || {}).flat();
    return Array.from(new Map(source.map((movie) => [movie.id, movie])).values());
  }, [catalog, query, searchResults]);

  const filtered = useMemo(() => liveMovies.filter((m) => {
    const q = query.toLowerCase();
    const matchesQuery = !q || [m.title, m.director, m.cast, ...m.providers].join(' ').toLowerCase().includes(q);
    const matchesPlatform = selectedPlatforms.length === 0 || m.providers.some((p) => selectedPlatforms.includes(p));
    const matchesGenre = selectedGenres.length === 0 || m.genres.some((g) => selectedGenres.includes(g));
    const matchesType = contentType === 'All' || m.type === contentType;
    return matchesQuery && matchesPlatform && matchesGenre && matchesType;
  }).sort((a, b) => b.rating - a.rating), [liveMovies, query, selectedPlatforms, selectedGenres, contentType]);

  if (boot) return <Splash />;
  if (!authed) return <Login onEnter={() => setAuthed(true)} />;
  if (detail) return <Details movie={detail} onBack={() => setDetail(null)} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} />;

  return <div className="app-shell" data-testid="movana-preview-app">
    <main className="phone-frame">
      {tab === 'home' && <HomeScreen filtered={filtered} catalog={catalog} loading={loading} searching={searching} error={error} query={query} setQuery={setQuery} selectedPlatforms={selectedPlatforms} setSelectedPlatforms={setSelectedPlatforms} selectedGenres={selectedGenres} setSelectedGenres={setSelectedGenres} contentType={contentType} setContentType={setContentType} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} openDetails={setDetail} />}
      {tab === 'watchlist' && <Library title="Watchlist" ids={watchlist} movies={liveMovies} empty="Your Watchlist is empty. Save titles from Home." openDetails={setDetail} />}
      {tab === 'theatre' && <Theatre watched={watched} movies={liveMovies} />}
      {tab === 'profile' && <Profile />}
      <BottomNav tab={tab} setTab={setTab} />
    </main>
  </div>;
}

function Splash() { return <div className="splash" data-testid="splash-screen"><img src={logo} alt="Movana" /><h1>Stop Scrolling,<br/>Start Watching</h1><div className="loader">Loading...</div></div>; }
function Login({ onEnter }) { return <div className="login" data-testid="login-screen"><img src={logo} alt="Movana" /><button data-testid="google-login" onClick={onEnter}>Continue with Google</button><button data-testid="guest-login" className="secondary" onClick={onEnter}>Continue as Guest</button><footer>Privacy Policy · Terms & Conditions</footer></div>; }

function HomeScreen(props) {
  return <section className="screen home" data-testid="home-screen">
    <header><div><p>Hello, Movana User</p><h2>Find what’s worth watching.</h2></div><img src={icon} alt="Movana icon" /></header>
    <label className="search"><Search size={20}/><input data-testid="home-search" placeholder="Search movies, series, actors, directors, studios" value={props.query} onChange={(e) => props.setQuery(e.target.value)} /></label>
    <Section title="Choose OTT Platforms" meta={`${props.selectedPlatforms.length} selected`}><Scroller items={platforms} selected={props.selectedPlatforms} setSelected={props.setSelectedPlatforms} /></Section>
    <Section title="Content Type"><div className="segments">{['All','Movie','Series'].map(t => <button data-testid={`type-${t}`} className={props.contentType === t ? 'active' : ''} onClick={() => props.setContentType(t)} key={t}>{t === 'Movie' ? 'Movies' : t}</button>)}</div></Section>
    <Section title="Genres" meta={`${props.selectedGenres.length} selected`}><div className="chips">{(props.catalog.genres || fallbackGenres).map(g => <button data-testid={`genre-${g}`} className={props.selectedGenres.includes(g) ? 'active' : ''} key={g} onClick={() => toggle(g, props.selectedGenres, props.setSelectedGenres)}>{g}</button>)}</div></Section>
    {props.loading && <div className="loading-state" data-testid="tmdb-loading">Loading live TMDB movies...</div>}
    {props.searching && <div className="loading-state" data-testid="tmdb-searching">Searching TMDB...</div>}
    {props.error && <div className="error-state" data-testid="tmdb-error">{props.error}</div>}
    <Section title={props.query ? 'Search Results' : 'Top Picks'} meta="Live TMDB">{props.filtered.length ? props.filtered.map(m => <MovieCard key={m.id} movie={m} {...props} />) : !props.loading && <div className="empty">Streaming Information Not Available</div>}</Section>
    {!props.query && Object.entries(categoryLabels).map(([key, label]) => <Section key={key} title={label} meta="Live TMDB">{(props.catalog.categories?.[key] || []).slice(0, 5).map(m => <MovieCard key={`${key}-${m.id}`} movie={m} {...props} />)}</Section>)}
  </section>;
}

function Section({ title, meta, children }) { return <section className="section"><div className="section-head"><h3>{title}</h3><span>{meta}</span></div>{children}</section>; }
function Scroller({ items, selected, setSelected }) { return <div className="scroller">{items.map(item => <button data-testid={`platform-${item}`} className={`platform ${selected.includes(item) ? 'active' : ''}`} onClick={() => toggle(item, selected, setSelected)} key={item}><PlayCircle size={20}/>{item}</button>)}</div>; }
function toggle(item, list, setList) { setList(list.includes(item) ? list.filter(x => x !== item) : [...list, item]); }

function MovieCard({ movie, watchlist, setWatchlist, watched, setWatched, openDetails }) {
  return <article className="movie-card" data-testid={`movie-card-${movie.id}`} onClick={() => openDetails(movie)}><img src={movie.poster} alt={movie.title}/><div><h4>{movie.title}</h4><p>{movie.year} · {movie.runtime} min · {movie.language}</p><strong><Star size={15}/> {movie.rating} ({movie.votes})</strong><p>{movie.genres.join(' · ')}</p><p className="overview">{movie.overview}</p><div className="provider-row">{movie.providers.length ? movie.providers.map(p => <span key={p}>{p}</span>) : <span>Currently in Theatres</span>}</div><div className="actions" onClick={(e) => e.stopPropagation()}><button className={watched.includes(movie.id) ? 'active yellow' : ''} onClick={() => toggle(movie.id, watched, setWatched)}><CheckCircle2 size={16}/> {watched.includes(movie.id) ? 'Watched' : 'Already Watched'}</button><button className={watchlist.includes(movie.id) ? 'active red' : ''} onClick={() => toggle(movie.id, watchlist, setWatchlist)}><Heart size={16}/> {watchlist.includes(movie.id) ? 'Saved' : 'Watchlist'}</button></div></div></article>;
}

function Details({ movie, onBack, watchlist, setWatchlist, watched, setWatched }) { const [full, setFull] = useState(movie); const [loading, setLoading] = useState(true); React.useEffect(() => { let alive = true; fetch(`/api/tmdb/movie/${movie.tmdbId || movie.id}`).then(r => r.ok ? r.json() : Promise.reject()).then(data => { if (alive) setFull(data); }).catch(() => {}).finally(() => { if (alive) setLoading(false); }); return () => { alive = false; }; }, [movie]); return <main className="details"><button className="back" onClick={onBack}>Back</button><div className="hero" style={{backgroundImage:`linear-gradient(180deg, rgba(13,13,13,.1), #0D0D0D), url(${full.backdrop})`}}/><section>{loading && <div className="loading-state">Loading details...</div>}<h1>{full.title}</h1><p>{full.year} · {full.runtime || 'Runtime TBA'} min · {full.age}</p><strong><Star size={18}/> {full.rating} · {full.votes} votes</strong><p>{full.overview}</p><dl><dt>Director</dt><dd>{full.director}</dd><dt>Cast</dt><dd>{full.cast}</dd><dt>Streaming</dt><dd>{full.providers?.length ? full.providers.join(', ') : 'Streaming Information Not Available'}</dd></dl><div className="actions"><button onClick={() => full.trailer && window.open(full.trailer, '_blank')}><PlayCircle size={16}/> Trailer</button><button onClick={() => toggle(full.id, watched, setWatched)}>Already Watched</button><button onClick={() => toggle(full.id, watchlist, setWatchlist)}>Watchlist</button><button><Share2 size={16}/> Share</button></div><h3>Similar Movies</h3>{(full.recommendations || []).slice(0,2).map(m => <MovieCard key={m.id} movie={m} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} openDetails={() => {}} />)}</section></main>; }
function Library({ title, ids, movies, empty, openDetails }) { const items = movies.filter(m => ids.includes(m.id)); return <section className="screen"><h2>{title}</h2><label className="search"><Search size={20}/><input placeholder="Search saved titles" /></label>{items.length ? items.map(m => <article className="grid-card" key={m.id} onClick={() => openDetails(m)}><img src={m.poster}/><b>{m.title}</b><span>{m.rating}</span></article>) : <div className="empty">{empty}</div>}</section>; }
function Theatre({ watched, movies }) { const count = watched.length; const picked = movies.filter(m => watched.includes(m.id)); const avg = picked.length ? (picked.reduce((s,m)=>s+m.rating,0)/picked.length).toFixed(1) : '0.0'; return <section className="screen"><h2>My Theatre</h2><div className="share-card"><img src={icon}/><h3>I’ve watched {count} titles</h3><p>Average Rating {avg}</p><b>Shared from Movana</b></div><button className="wide"><Share2 size={16}/> Generate Share Image</button><div className="stats"><span>Movies Watched <b>{picked.filter(m=>m.type==='Movie').length}</b></span><span>Series Watched <b>{picked.filter(m=>m.type==='Series').length}</b></span><span>Favourite Genre <b>{picked[0]?.genres[0] || '—'}</b></span><span>Hours Watched <b>{Math.floor(picked.reduce((s,m)=>s+(m.runtime || 0),0)/60)}</b></span></div></section>; }
function Profile() { return <section className="screen"><h2>Profile</h2><div className="profile"><img src={icon}/><div><b>Movana User</b><p>demo@movana.app</p></div></div>{['Notification Settings','Language','Privacy','About Movana','Share Movana','Delete Account','Logout'].map((x,i)=><button className="tile" key={x}>{i===0?<Bell/>:i===4?<Share2/>:<UserRound/>}{x}</button>)}<div className="admin"><Shield/><div><b>Admin Dashboard</b><p>Banners, featured movies, push notifications, affiliates, ads and analytics.</p></div><BarChart3/></div></section>; }
function BottomNav({ tab, setTab }) { const items = [['home',Home],['watchlist',Heart],['theatre',Theater],['profile',UserRound]]; return <nav>{items.map(([id,Icon]) => <button data-testid={`nav-${id}`} className={tab===id?'active':''} onClick={() => setTab(id)} key={id}><Icon size={22}/><span>{id === 'theatre' ? 'My Theatre' : id}</span></button>)}</nav>; }

createRoot(document.getElementById('root')).render(<App />);
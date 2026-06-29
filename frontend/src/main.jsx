import React, { useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Check, ChevronLeft, Clapperboard, Heart, Home, Search, Share2, Star, Tv } from 'lucide-react';
import './styles.css';

const logo = '/assets/images/movana_logo.png';
const icon = '/assets/images/movana_icon.png';

const fallbackProviders = [
  { id: 8, name: 'Netflix', logoText: 'N' },
  { id: 119, name: 'Prime Video', logoText: 'prime' },
  { id: 122, name: 'Disney+ Hotstar', logoText: 'hotstar' },
  { id: 237, name: 'Sony LIV', logoText: 'LIV' },
  { id: 232, name: 'ZEE5', logoText: 'ZEE5' },
  { id: 2, name: 'Apple TV+', logoText: 'tv+' },
  { id: 515, name: 'MX Player', logoText: 'MX' },
  { id: 532, name: 'Aha', logoText: 'aha' },
  { id: 309, name: 'Sun NXT', logoText: 'sun' },
];

const ratingOptions = [
  ['top', 'Top Rated'],
  ['8_10', '8.0 to 10.0 rated'],
  ['6_8', '6.0 to 8.0 rated'],
  ['4_6', '4.0 to 6.0 rated'],
  ['1_4', '1.0 to 4.0 rated'],
];
const timeOptions = [['all', 'All Time'], ['latest', 'Latest to Oldest'], ['oldest', 'Oldest to Latest']];

function App() {
  const [boot, setBoot] = useState(true);
  const [authed, setAuthed] = useState(false);
  const [step, setStep] = useState('ott');
  const [tab, setTab] = useState('home');
  const [providers, setProviders] = useState(fallbackProviders);
  const [provider, setProvider] = useState(null);
  const [contentType, setContentType] = useState(null);
  const [genres, setGenres] = useState([]);
  const [genre, setGenre] = useState(null);
  const [movies, setMovies] = useState([]);
  const [searchResults, setSearchResults] = useState([]);
  const [query, setQuery] = useState('');
  const [rating, setRating] = useState('top');
  const [time, setTime] = useState('all');
  const [watchlist, setWatchlist] = useState([]);
  const [watched, setWatched] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => { const timer = setTimeout(() => setBoot(false), 1200); return () => clearTimeout(timer); }, []);
  useEffect(() => { fetch('/api/tmdb/providers').then(r => r.json()).then(d => setProviders(d.providers?.length ? d.providers : fallbackProviders)).catch(() => setProviders(fallbackProviders)); }, []);

  useEffect(() => {
    if (!contentType) return;
    setLoading(true);
    fetch(`/api/tmdb/genres?content_type=${contentType === 'Movie' ? 'movie' : 'tv'}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(d => { setGenres(d.genres || []); setError(''); })
      .catch(() => setError('Unable to load genres. Please try again.'))
      .finally(() => setLoading(false));
  }, [contentType]);

  useEffect(() => {
    if (!provider || !contentType || !genre || step !== 'list') return;
    setLoading(true);
    const type = contentType === 'Movie' ? 'movie' : 'tv';
    fetch(`/api/tmdb/discover?content_type=${type}&genre_id=${genre.id}&provider_id=${provider.id}&rating=${rating}&time=${time}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(d => { setMovies(d.results || []); setError(''); })
      .catch(() => setError('Unable to load titles. Please try again.'))
      .finally(() => setLoading(false));
  }, [provider, contentType, genre, rating, time, step]);

  useEffect(() => {
    const q = query.trim();
    if (!q) { setSearchResults([]); return; }
    const timer = setTimeout(() => {
      fetch(`/api/tmdb/search?q=${encodeURIComponent(q)}`)
        .then(r => r.ok ? r.json() : Promise.reject())
        .then(d => setSearchResults(d.results || []))
        .catch(() => setError('Search failed. Please try again.'));
    }, 300);
    return () => clearTimeout(timer);
  }, [query]);

  const list = useMemo(() => query.trim() ? searchResults : movies, [query, searchResults, movies]);
  const watchedMovies = useMemo(() => allKnown(list, watchlist, watched).filter(m => watched.includes(m.id)), [list, watchlist, watched]);
  const watchlistMovies = useMemo(() => allKnown(list, watchlist, watched).filter(m => watchlist.includes(m.id)), [list, watchlist, watched]);

  if (boot) return <Splash />;
  if (!authed) return <Login onEnter={() => { setAuthed(true); setStep('ott'); }} />;

  return <div className="app-shell" data-testid="movana-redesign-app"><main className="phone-frame redesigned">
    {tab === 'home' && step === 'ott' && <OttSelection providers={providers} onSelect={(p) => { setProvider(p); setStep('platform'); }} />}
    {tab === 'home' && step === 'platform' && <PlatformHome provider={provider} query={query} setQuery={setQuery} searchResults={searchResults} onBack={() => setStep('ott')} onType={(type) => { setContentType(type); setStep('genre'); }} />}
    {tab === 'home' && step === 'genre' && <GenreSelection genres={genres} loading={loading} error={error} onBack={() => setStep('platform')} onSelect={(g) => { setGenre(g); setStep('list'); }} />}
    {tab === 'home' && step === 'list' && <MovieList provider={provider} genre={genre} contentType={contentType} movies={list} loading={loading} error={error} rating={rating} setRating={setRating} time={time} setTime={setTime} query={query} setQuery={setQuery} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} onBack={() => setStep('genre')} />}
    {tab === 'theatre' && <Collection title="My Theatre" movies={watchedMovies} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} theatre />}
    {tab === 'watchlist' && <Collection title="Watchlist" movies={watchlistMovies} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} />}
    <BottomNav tab={tab} setTab={(next) => { setTab(next); if (next === 'home' && !provider) setStep('ott'); }} />
  </main></div>;
}

function allKnown(current) { return current; }
function Splash() { return <div className="splash"><img src={logo} alt="Movana"/><h1>Stop Scrolling,<br/>Start Watching</h1><div className="loader">Loading...</div></div>; }
function Login({ onEnter }) { return <div className="login" data-testid="login-screen"><img src={logo} alt="Movana"/><button data-testid="google-login" onClick={onEnter}>Continue with Google</button><button data-testid="guest-login" className="secondary" onClick={onEnter}>Continue as Guest</button><footer>Privacy Policy · Terms & Conditions</footer></div>; }
function BackButton({ onClick }) { return <button className="icon-back" data-testid="back-button" onClick={onClick}><ChevronLeft size={28}/></button>; }

function OttSelection({ providers, onSelect }) { return <section className="screen flow-screen" data-testid="ott-selection-screen"><h1>Choose your<br/>OTT Platform</h1><p>Select your preferred platform to browse content.</p><div className="ott-grid">{providers.map(p => <button className="ott-card pressable" data-testid={`ott-${p.name}`} key={p.id || p.name} onClick={() => onSelect(p)}>{p.logo ? <img src={p.logo} alt={p.name}/> : <b>{p.logoText || p.name[0]}</b>}<span>{p.name}</span></button>)}</div><small>You can change this later.</small></section>; }

function PlatformHome({ provider, query, setQuery, searchResults, onBack, onType }) { return <section className="screen flow-screen" data-testid="platform-home-screen"><BackButton onClick={onBack}/><h1 className="provider-title">{provider?.name || 'MOVANA'}</h1><SearchBox value={query} onChange={setQuery}/>{query && <div className="quick-search">{searchResults.slice(0,4).map(m => <div key={m.id}><img src={m.poster}/><span>{m.title}</span></div>)}</div>}<div className="type-grid"><button className="type-card movie pressable" data-testid="movies-button" onClick={() => onType('Movie')}><Clapperboard size={70}/><b>MOVIES</b></button><button className="type-card series pressable" data-testid="series-button" onClick={() => onType('Series')}><Tv size={70}/><b>SERIES</b></button></div></section>; }

function GenreSelection({ genres, loading, error, onBack, onSelect }) { return <section className="screen flow-screen" data-testid="genre-selection-screen"><BackButton onClick={onBack}/><h1>Select Genre</h1><p>Choose a genre to explore content.</p>{loading && <Shimmer text="Loading genres..."/>}{error && <div className="error-state">{error}</div>}<div className="genre-grid">{genres.map(g => <button data-testid={`genre-card-${g.name}`} className="genre-card pressable" key={g.id} onClick={() => onSelect(g)} style={{backgroundImage:`linear-gradient(rgba(0,0,0,.48),rgba(0,0,0,.62)),url(${g.backdrop || g.poster})`}}><span>{g.name.toUpperCase()}</span></button>)}</div></section>; }

function MovieList({ provider, genre, contentType, movies, loading, error, rating, setRating, time, setTime, query, setQuery, watchlist, setWatchlist, watched, setWatched, onBack }) { return <section className="screen list-screen" data-testid="movie-list-screen"><BackButton onClick={onBack}/><h1>{genre?.name} {contentType}s</h1><SearchBox value={query} onChange={setQuery}/><div className="filter-row"><SelectPill value={rating} options={ratingOptions} onChange={setRating}/><SelectPill value={time} options={timeOptions} onChange={setTime}/></div>{loading && <Shimmer text="Loading top rated titles..."/>}{error && <div className="error-state">{error}</div>}{!loading && movies.length === 0 && <div className="empty">No titles found for {provider?.name}. Try another filter.</div>}<div className="rank-list">{movies.map((m,i) => <RankedMovie key={m.id} rank={i+1} movie={m} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist}/>)}</div></section>; }

function RankedMovie({ rank, movie, watched, watchlist, setWatched, setWatchlist }) { const seen = watched.includes(movie.id); const saved = watchlist.includes(movie.id); return <article className="rank-card" data-testid={`movie-card-${movie.id}`}><span className="rank">{rank}</span><div className="poster-wrap"><img src={movie.poster} alt={movie.title}/><button className={`watched-pill ${seen ? 'on' : ''}`} onClick={() => toggle(movie.id, watched, setWatched)}>Already Watched</button><button className={`heart-btn ${saved ? 'on' : ''}`} onClick={() => toggle(movie.id, watchlist, setWatchlist)}><Heart size={19} fill={saved ? 'currentColor' : 'none'}/></button></div><div className="rank-info"><h2>{movie.title}</h2><strong><Star size={16} fill="currentColor"/> {movie.rating}</strong><p>{movie.year || 'TBA'} · {movie.runtime ? `${Math.floor(movie.runtime/60)}h ${movie.runtime%60}m` : 'Runtime TBA'}</p><p className="overview">{movie.overview}</p></div></article>; }

function Collection({ title, movies, watched, watchlist, setWatched, setWatchlist, theatre }) { return <section className="screen collection-screen" data-testid={`${title.toLowerCase().replaceAll(' ','-')}-screen`}><h1>{title}</h1>{theatre && <div className="share-card"><img src={icon}/><h2>My Theatre</h2><p>{movies.filter(m=>m.type==='Movie').length} Movies</p><p>{movies.filter(m=>m.type==='Series').length} Series</p><button><Share2 size={16}/> Share Theatre</button></div>}{movies.length === 0 ? <div className="empty">{theatre ? 'Mark titles as Already Watched to build your theatre.' : 'Tap the heart button to save titles here.'}</div> : <div className="collection-grid">{movies.map(m => <div className="collection-card" key={m.id}><img src={m.poster}/><button className="watched-pill on">{theatre ? 'Already Watched' : m.title}</button><button className={`heart-btn ${watchlist.includes(m.id) ? 'on' : ''}`} onClick={() => theatre ? toggle(m.id, watched, setWatched) : toggle(m.id, watchlist, setWatchlist)}><Heart size={16} fill="currentColor"/></button></div>)}</div>}</section>; }

function SearchBox({ value, onChange }) { return <label className="search"><Search size={22}/><input data-testid="global-search" value={value} onChange={e => onChange(e.target.value)} placeholder="Search movies, series, actors..."/></label>; }
function SelectPill({ value, options, onChange }) { return <select className="filter-select" data-testid={`filter-${value}`} value={value} onChange={e => onChange(e.target.value)}>{options.map(([v,l]) => <option key={v} value={v}>{l}</option>)}</select>; }
function Shimmer({ text }) { return <div className="loading-state" data-testid="loading-state">{text}</div>; }
function toggle(item, list, setList) { setList(list.includes(item) ? list.filter(x => x !== item) : [...list, item]); }
function BottomNav({ tab, setTab }) { return <nav className="minimal-nav" data-testid="bottom-navigation"><button className={tab === 'home' ? 'active' : ''} onClick={() => setTab('home')}><Home/><span>Home</span></button><button className={tab === 'theatre' ? 'active' : ''} onClick={() => setTab('theatre')}><Clapperboard/><span>My Theatre</span></button><button className={tab === 'watchlist' ? 'active' : ''} onClick={() => setTab('watchlist')}><Heart/><span>Watchlist</span></button></nav>; }

createRoot(document.getElementById('root')).render(<App />);
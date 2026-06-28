import React, { useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Film, Heart, Home, Search, Star, Theater, UserRound, Shield, Bell, BarChart3, Share2, PlayCircle, CheckCircle2 } from 'lucide-react';
import './styles.css';

const logo = '/assets/images/movana_logo.png';
const icon = '/assets/images/movana_icon.png';

const platforms = ['Netflix', 'Amazon Prime Video', 'JioHotstar', 'Sony LIV', 'ZEE5', 'Apple TV+', 'JioCinema', 'MX Player', 'Lionsgate Play', 'Crunchyroll', 'MUBI'];
const genres = ['Action', 'Adventure', 'Animation', 'Biography', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family', 'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Sci-Fi', 'Sport', 'Thriller', 'War', 'Western'];
const movies = [
  { id: 'interstellar', title: 'Interstellar', year: 2014, rating: 8.7, votes: 35200, genres: ['Adventure', 'Drama', 'Sci-Fi'], runtime: 169, language: 'English', providers: ['Amazon Prime Video', 'Apple TV+'], age: 'U/A 13+', type: 'Movie', director: 'Christopher Nolan', cast: 'Matthew McConaughey, Anne Hathaway, Jessica Chastain', poster: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', backdrop: 'https://image.tmdb.org/t/p/w1280/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg', overview: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity’s survival.' },
  { id: 'dark-knight', title: 'The Dark Knight', year: 2008, rating: 9.0, votes: 33000, genres: ['Action', 'Crime', 'Drama'], runtime: 152, language: 'English', providers: ['Netflix', 'JioHotstar'], age: 'U/A 16+', type: 'Movie', director: 'Christopher Nolan', cast: 'Christian Bale, Heath Ledger, Aaron Eckhart', poster: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg', backdrop: 'https://image.tmdb.org/t/p/w1280/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg', overview: 'Batman faces the Joker, a criminal mastermind who plunges Gotham into chaos.' },
  { id: 'dune-part-two', title: 'Dune: Part Two', year: 2024, rating: 8.5, votes: 6200, genres: ['Adventure', 'Sci-Fi'], runtime: 166, language: 'English', providers: [], age: 'U/A 13+', type: 'Movie', director: 'Denis Villeneuve', cast: 'Timothée Chalamet, Zendaya, Rebecca Ferguson', poster: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg', backdrop: 'https://image.tmdb.org/t/p/w1280/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg', overview: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators.' },
  { id: 'breaking-bad', title: 'Breaking Bad', year: 2008, rating: 9.5, votes: 22000, genres: ['Crime', 'Drama', 'Thriller'], runtime: 49, language: 'English', providers: ['Netflix'], age: 'A', type: 'Series', director: 'Vince Gilligan', cast: 'Bryan Cranston, Aaron Paul, Anna Gunn', poster: 'https://image.tmdb.org/t/p/w500/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg', backdrop: 'https://image.tmdb.org/t/p/w1280/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg', overview: 'A high school chemistry teacher turns to manufacturing methamphetamine after a diagnosis.' },
  { id: 'panchayat', title: 'Panchayat', year: 2020, rating: 8.8, votes: 3200, genres: ['Comedy', 'Drama'], runtime: 35, language: 'Hindi', providers: ['Amazon Prime Video'], age: 'U/A 13+', type: 'Series', director: 'Deepak Kumar Mishra', cast: 'Jitendra Kumar, Neena Gupta, Raghubir Yadav', poster: 'https://image.tmdb.org/t/p/w500/9wG1S1mDdcIuv2D2ZrHMJdGHmSO.jpg', backdrop: 'https://image.tmdb.org/t/p/w1280/7lTnXOy0iNtBAdRP3TZvaKJ77F6.jpg', overview: 'An engineering graduate joins as secretary of a remote village panchayat office.' },
];

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

  React.useEffect(() => { const timer = setTimeout(() => setBoot(false), 1400); return () => clearTimeout(timer); }, []);

  const filtered = useMemo(() => movies.filter((m) => {
    const q = query.toLowerCase();
    const matchesQuery = !q || [m.title, m.director, m.cast, ...m.providers].join(' ').toLowerCase().includes(q);
    const matchesPlatform = selectedPlatforms.length === 0 || m.providers.some((p) => selectedPlatforms.includes(p));
    const matchesGenre = selectedGenres.length === 0 || m.genres.some((g) => selectedGenres.includes(g));
    const matchesType = contentType === 'All' || m.type === contentType;
    return matchesQuery && matchesPlatform && matchesGenre && matchesType;
  }).sort((a, b) => b.rating - a.rating), [query, selectedPlatforms, selectedGenres, contentType]);

  if (boot) return <Splash />;
  if (!authed) return <Login onEnter={() => setAuthed(true)} />;
  if (detail) return <Details movie={detail} onBack={() => setDetail(null)} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} />;

  return <div className="app-shell" data-testid="movana-preview-app">
    <main className="phone-frame">
      {tab === 'home' && <HomeScreen filtered={filtered} query={query} setQuery={setQuery} selectedPlatforms={selectedPlatforms} setSelectedPlatforms={setSelectedPlatforms} selectedGenres={selectedGenres} setSelectedGenres={setSelectedGenres} contentType={contentType} setContentType={setContentType} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} openDetails={setDetail} />}
      {tab === 'watchlist' && <Library title="Watchlist" ids={watchlist} empty="Your Watchlist is empty. Save titles from Home." openDetails={setDetail} />}
      {tab === 'theatre' && <Theatre watched={watched} />}
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
    <Section title="Genres" meta={`${props.selectedGenres.length} selected`}><div className="chips">{genres.map(g => <button data-testid={`genre-${g}`} className={props.selectedGenres.includes(g) ? 'active' : ''} key={g} onClick={() => toggle(g, props.selectedGenres, props.setSelectedGenres)}>{g}</button>)}</div></Section>
    <Section title="Top Picks" meta="TMDB-ready">{props.filtered.length ? props.filtered.map(m => <MovieCard key={m.id} movie={m} {...props} />) : <div className="empty">Streaming Information Not Available</div>}</Section>
  </section>;
}

function Section({ title, meta, children }) { return <section className="section"><div className="section-head"><h3>{title}</h3><span>{meta}</span></div>{children}</section>; }
function Scroller({ items, selected, setSelected }) { return <div className="scroller">{items.map(item => <button data-testid={`platform-${item}`} className={`platform ${selected.includes(item) ? 'active' : ''}`} onClick={() => toggle(item, selected, setSelected)} key={item}><PlayCircle size={20}/>{item}</button>)}</div>; }
function toggle(item, list, setList) { setList(list.includes(item) ? list.filter(x => x !== item) : [...list, item]); }

function MovieCard({ movie, watchlist, setWatchlist, watched, setWatched, openDetails }) {
  return <article className="movie-card" data-testid={`movie-card-${movie.id}`} onClick={() => openDetails(movie)}><img src={movie.poster} alt={movie.title}/><div><h4>{movie.title}</h4><p>{movie.year} · {movie.runtime} min · {movie.language}</p><strong><Star size={15}/> {movie.rating} ({movie.votes})</strong><p>{movie.genres.join(' · ')}</p><p className="overview">{movie.overview}</p><div className="provider-row">{movie.providers.length ? movie.providers.map(p => <span key={p}>{p}</span>) : <span>Currently in Theatres</span>}</div><div className="actions" onClick={(e) => e.stopPropagation()}><button className={watched.includes(movie.id) ? 'active yellow' : ''} onClick={() => toggle(movie.id, watched, setWatched)}><CheckCircle2 size={16}/> {watched.includes(movie.id) ? 'Watched' : 'Already Watched'}</button><button className={watchlist.includes(movie.id) ? 'active red' : ''} onClick={() => toggle(movie.id, watchlist, setWatchlist)}><Heart size={16}/> {watchlist.includes(movie.id) ? 'Saved' : 'Watchlist'}</button></div></div></article>;
}

function Details({ movie, onBack, watchlist, setWatchlist, watched, setWatched }) { return <main className="details"><button className="back" onClick={onBack}>Back</button><div className="hero" style={{backgroundImage:`linear-gradient(180deg, rgba(13,13,13,.1), #0D0D0D), url(${movie.backdrop})`}}/><section><h1>{movie.title}</h1><p>{movie.year} · {movie.runtime} min · {movie.age}</p><strong><Star size={18}/> {movie.rating} · {movie.votes} votes</strong><p>{movie.overview}</p><dl><dt>Director</dt><dd>{movie.director}</dd><dt>Cast</dt><dd>{movie.cast}</dd><dt>Streaming</dt><dd>{movie.providers.length ? movie.providers.join(', ') : 'Currently in Theatres'}</dd></dl><div className="actions"><button><PlayCircle size={16}/> Trailer</button><button onClick={() => toggle(movie.id, watched, setWatched)}>Already Watched</button><button onClick={() => toggle(movie.id, watchlist, setWatchlist)}>Watchlist</button><button><Share2 size={16}/> Share</button></div><h3>Similar Movies</h3>{movies.filter(m => m.id !== movie.id).slice(0,2).map(m => <MovieCard key={m.id} movie={m} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} openDetails={() => {}} />)}</section></main>; }
function Library({ title, ids, empty, openDetails }) { const items = movies.filter(m => ids.includes(m.id)); return <section className="screen"><h2>{title}</h2><label className="search"><Search size={20}/><input placeholder="Search saved titles" /></label>{items.length ? items.map(m => <article className="grid-card" key={m.id} onClick={() => openDetails(m)}><img src={m.poster}/><b>{m.title}</b><span>{m.rating}</span></article>) : <div className="empty">{empty}</div>}</section>; }
function Theatre({ watched }) { const count = watched.length; const picked = movies.filter(m => watched.includes(m.id)); const avg = picked.length ? (picked.reduce((s,m)=>s+m.rating,0)/picked.length).toFixed(1) : '0.0'; return <section className="screen"><h2>My Theatre</h2><div className="share-card"><img src={icon}/><h3>I’ve watched {count} titles</h3><p>Average Rating {avg}</p><b>Shared from Movana</b></div><button className="wide"><Share2 size={16}/> Generate Share Image</button><div className="stats"><span>Movies Watched <b>{picked.filter(m=>m.type==='Movie').length}</b></span><span>Series Watched <b>{picked.filter(m=>m.type==='Series').length}</b></span><span>Favourite Genre <b>{picked[0]?.genres[0] || '—'}</b></span><span>Hours Watched <b>{Math.floor(picked.reduce((s,m)=>s+m.runtime,0)/60)}</b></span></div></section>; }
function Profile() { return <section className="screen"><h2>Profile</h2><div className="profile"><img src={icon}/><div><b>Movana User</b><p>demo@movana.app</p></div></div>{['Notification Settings','Language','Privacy','About Movana','Share Movana','Delete Account','Logout'].map((x,i)=><button className="tile" key={x}>{i===0?<Bell/>:i===4?<Share2/>:<UserRound/>}{x}</button>)}<div className="admin"><Shield/><div><b>Admin Dashboard</b><p>Banners, featured movies, push notifications, affiliates, ads and analytics.</p></div><BarChart3/></div></section>; }
function BottomNav({ tab, setTab }) { const items = [['home',Home],['watchlist',Heart],['theatre',Theater],['profile',UserRound]]; return <nav>{items.map(([id,Icon]) => <button data-testid={`nav-${id}`} className={tab===id?'active':''} onClick={() => setTab(id)} key={id}><Icon size={22}/><span>{id === 'theatre' ? 'My Theatre' : id}</span></button>)}</nav>; }

createRoot(document.getElementById('root')).render(<App />);
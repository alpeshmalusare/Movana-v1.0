import React, { useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Check, ChevronLeft, Clapperboard, Heart, Home, Play, Search, Share2, Star, Tv, X } from 'lucide-react';
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
const languageOptions = [['all','All Languages'],['en','English'],['hi','Hindi'],['ta','Tamil'],['te','Telugu'],['ml','Malayalam'],['kn','Kannada'],['bn','Bengali'],['mr','Marathi'],['pa','Punjabi'],['gu','Gujarati'],['ko','Korean'],['ja','Japanese'],['zh','Chinese'],['es','Spanish'],['fr','French'],['de','German'],['it','Italian'],['tr','Turkish'],['th','Thai'],['id','Indonesian'],['ru','Russian'],['ar','Arabic']];

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
  const [language, setLanguage] = useState('all');
  const [watchlist, setWatchlist] = useState([]);
  const [watched, setWatched] = useState([]);
  const [knownTitles, setKnownTitles] = useState({});
  const [selectedTitle, setSelectedTitle] = useState(null);
  const [details, setDetails] = useState(null);
  const [detailsLoading, setDetailsLoading] = useState(false);
  const [shareLoading, setShareLoading] = useState(false);
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
    fetch(`/api/tmdb/discover?content_type=${type}&genre_id=${genre.id}&provider_id=${provider.id}&rating=${rating}&time=${time}&language=${language}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(d => { setMovies(d.results || []); setError(''); })
      .catch(() => setError('Unable to load titles. Please try again.'))
      .finally(() => setLoading(false));
  }, [provider, contentType, genre, rating, time, language, step]);

  useEffect(() => {
    if (!selectedTitle) return;
    setDetailsLoading(true);
    const type = selectedTitle.type === 'Series' ? 'tv' : 'movie';
    fetch(`/api/tmdb/title/${type}/${selectedTitle.tmdbId || selectedTitle.id}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(d => setDetails(d))
      .catch(() => setError('Unable to load details. Please try again.'))
      .finally(() => setDetailsLoading(false));
  }, [selectedTitle]);

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

  useEffect(() => { setKnownTitles(prev => mergeKnown(prev, movies)); }, [movies]);
  useEffect(() => { setKnownTitles(prev => mergeKnown(prev, searchResults)); }, [searchResults]);
  useEffect(() => { if (details) setKnownTitles(prev => mergeKnown(prev, [details])); }, [details]);

  const list = useMemo(() => query.trim() ? searchResults : movies, [query, searchResults, movies]);
  const watchedMovies = useMemo(() => watched.map(id => knownTitles[id]).filter(Boolean), [knownTitles, watched]);
  const watchlistMovies = useMemo(() => watchlist.map(id => knownTitles[id]).filter(Boolean), [knownTitles, watchlist]);

  if (boot) return <Splash />;
  if (!authed) return <Login onEnter={() => { setAuthed(true); setStep('ott'); }} />;

  return <div className="app-shell" data-testid="movana-redesign-app"><main className="phone-frame redesigned">
    {tab === 'home' && step === 'ott' && <OttSelection selected={provider} providers={providers} onSelect={(p) => { setProvider(p); setRating('top'); setTime('all'); setLanguage('all'); setStep('platform'); }} />}
    {tab === 'home' && step === 'platform' && <PlatformHome provider={provider} query={query} setQuery={setQuery} searchResults={searchResults} onBack={() => setStep('ott')} onType={(type) => { setContentType(type); setStep('genre'); }} />}
    {tab === 'home' && step === 'genre' && <GenreSelection genres={genres} loading={loading} error={error} onBack={() => setStep('platform')} onSelect={(g) => { setGenre(g); setStep('list'); }} />}
    {tab === 'home' && step === 'list' && <MovieList provider={provider} genre={genre} contentType={contentType} movies={list} loading={loading} error={error} rating={rating} setRating={setRating} time={time} setTime={setTime} language={language} setLanguage={setLanguage} query={query} setQuery={setQuery} watchlist={watchlist} setWatchlist={setWatchlist} watched={watched} setWatched={setWatched} onOpen={setSelectedTitle} onBack={() => setStep('genre')} />}
    {tab === 'theatre' && <Collection title="My Theatre" movies={watchedMovies} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} theatre shareLoading={shareLoading} onShare={() => shareTheatre(watchedMovies, provider, setShareLoading)} />}
    {tab === 'watchlist' && <Collection title="Watchlist" movies={watchlistMovies} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} />}
    <BottomNav tab={tab} setTab={(next) => { setTab(next); if (next === 'home') { setStep('ott'); setSelectedTitle(null); setDetails(null); setRating('top'); setTime('all'); setLanguage('all'); } }} />
    {selectedTitle && <DetailsOverlay movie={details || selectedTitle} loading={detailsLoading} selectedProvider={provider} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} onClose={() => { setSelectedTitle(null); setDetails(null); }} />}
  </main></div>;
}

function mergeKnown(prev, items) { const next = {...prev}; (items || []).forEach(item => { if (item?.id) next[item.id] = item; }); return next; }
function Splash() { return <div className="splash"><img src={logo} alt="Movana"/><h1>Stop Scrolling,<br/>Start Watching</h1><div className="loader">Loading...</div></div>; }
function Login({ onEnter }) { return <div className="login" data-testid="login-screen"><img src={logo} alt="Movana"/><button data-testid="google-login" onClick={onEnter}>Continue with Google</button><button data-testid="guest-login" className="secondary" onClick={onEnter}>Continue as Guest</button><footer>Privacy Policy · Terms & Conditions</footer></div>; }
function BackButton({ onClick }) { return <button className="icon-back" data-testid="back-button" onClick={onClick}><ChevronLeft size={28}/></button>; }

function OttSelection({ providers, selected, onSelect }) { return <section className="screen flow-screen" data-testid="ott-selection-screen"><h1>Choose your<br/>OTT Platform</h1><p>Select one platform to browse. You can always discover where else a title is streaming.</p><div className="ott-grid premium">{providers.map(p => <button className={`ott-card premium pressable ${selected?.id===p.id?'selected':''}`} data-testid={`ott-${p.name}`} key={p.id || p.name} onClick={() => onSelect(p)}>{selected?.id===p.id && <span className="checkmark"><Check size={15}/></span>}{p.logo ? <img src={p.logo} alt={p.name}/> : <b>{p.logoText || p.name[0]}</b>}<span>{p.name}</span></button>)}</div></section>; }

function PlatformHome({ provider, query, setQuery, searchResults, onBack, onType }) { return <section className="screen flow-screen" data-testid="platform-home-screen"><BackButton onClick={onBack}/><h1 className="provider-title">{provider?.name || 'MOVANA'}</h1><SearchBox value={query} onChange={setQuery}/>{query && <div className="quick-search">{searchResults.slice(0,4).map(m => <div key={m.id}><img src={m.poster}/><span>{m.title}</span></div>)}</div>}<div className="type-grid"><button className="type-card movie pressable" data-testid="movies-button" onClick={() => onType('Movie')}><Clapperboard size={70}/><b>MOVIES</b></button><button className="type-card series pressable" data-testid="series-button" onClick={() => onType('Series')}><Tv size={70}/><b>SERIES</b></button></div></section>; }

function GenreSelection({ genres, loading, error, onBack, onSelect }) { return <section className="screen flow-screen" data-testid="genre-selection-screen"><BackButton onClick={onBack}/><h1>Select Genre</h1><p>Choose a genre to explore content.</p>{loading && <Shimmer text="Loading genres..."/>}{error && <div className="error-state">{error}</div>}<div className="genre-grid">{genres.map(g => <button data-testid={`genre-card-${g.name}`} className="genre-card pressable" key={g.id} onClick={() => onSelect(g)} style={{backgroundImage:`linear-gradient(rgba(0,0,0,.48),rgba(0,0,0,.62)),url(${g.backdrop || g.poster})`}}><span>{g.name.toUpperCase()}</span></button>)}</div></section>; }

function MovieList({ provider, genre, contentType, movies, loading, error, rating, setRating, time, setTime, language, setLanguage, query, setQuery, watchlist, setWatchlist, watched, setWatched, onOpen, onBack }) { return <section className="screen list-screen" data-testid="movie-list-screen"><BackButton onClick={onBack}/><h1>{genre?.name} {contentType}s</h1><SearchBox value={query} onChange={setQuery}/><div className="filter-row triple"><SelectPill value={rating} options={ratingOptions} onChange={setRating}/><SelectPill value={time} options={timeOptions} onChange={setTime}/><SelectPill value={language} options={languageOptions} onChange={setLanguage}/></div>{loading && <Shimmer text="Loading top rated titles..."/>}{error && <div className="error-state">{error}</div>}{!loading && movies.length === 0 && <div className="empty">No titles found for {provider?.name}. Try another filter.</div>}<div className="rank-list">{movies.map((m,i) => <RankedMovie key={m.id} rank={i+1} movie={m} watched={watched} watchlist={watchlist} setWatched={setWatched} setWatchlist={setWatchlist} onOpen={onOpen}/>)}</div></section>; }

function RankedMovie({ rank, movie, watched, watchlist, setWatched, setWatchlist, onOpen }) { const seen = watched.includes(movie.id); const saved = watchlist.includes(movie.id); return <article className="rank-card clickable" data-testid={`movie-card-${movie.id}`} onClick={() => onOpen(movie)}><span className="rank">{rank}</span><div className="poster-wrap"><img src={movie.poster} alt={movie.title}/><button className={`watched-pill ${seen ? 'on' : ''}`} onClick={(e) => {e.stopPropagation(); toggle(movie.id, watched, setWatched);}}>Already Watched</button><button className={`heart-btn ${saved ? 'on' : ''}`} onClick={(e) => {e.stopPropagation(); toggle(movie.id, watchlist, setWatchlist);}}><Heart size={19} fill={saved ? 'currentColor' : 'none'}/></button></div><div className="rank-info"><h2>{movie.title}</h2><strong><Star size={16} fill="currentColor"/> {movie.rating}</strong><p>{movie.year || 'TBA'} · {movie.runtime ? `${Math.floor(movie.runtime/60)}h ${movie.runtime%60}m` : 'Runtime TBA'}</p><p className="overview">{movie.overview}</p></div></article>; }

function Collection({ title, movies, watched, watchlist, setWatched, setWatchlist, theatre, shareLoading, onShare }) { return <section className="screen collection-screen" data-testid={`${title.toLowerCase().replaceAll(' ','-')}-screen`}><h1>{title}</h1>{theatre && <div className="share-card"><img src={icon}/><h2>My Theatre</h2><p>{movies.filter(m=>m.type==='Movie').length} Movies</p><p>{movies.filter(m=>m.type==='Series').length} Series</p><p>Theatre Score: {Math.min(100, 60 + movies.length * 4)}/100</p><button onClick={onShare} disabled={shareLoading}><Share2 size={16}/> {shareLoading ? 'Preparing your theatre...' : 'Share Theatre'}</button></div>}{movies.length === 0 ? <div className="empty">{theatre ? 'Mark titles as Already Watched to build your theatre.' : 'Tap the heart button to save titles here.'}</div> : <div className="collection-grid">{movies.map(m => <div className="collection-card" key={m.id}><img src={m.poster}/><button className="watched-pill on">{theatre ? 'Already Watched' : m.title}</button><button className={`heart-btn ${watchlist.includes(m.id) ? 'on' : ''}`} onClick={() => theatre ? toggle(m.id, watched, setWatched) : toggle(m.id, watchlist, setWatchlist)}><Heart size={16} fill="currentColor"/></button></div>)}</div>}</section>; }

function DetailsOverlay({ movie, loading, selectedProvider, watched, watchlist, setWatched, setWatchlist, onClose }) { const seen = watched.includes(movie.id); const saved = watchlist.includes(movie.id); return <div className="details-overlay" data-testid="details-page"><div className="details-panel"><button className="close-btn" onClick={onClose}><X/></button><div className="details-hero" style={{backgroundImage:`linear-gradient(180deg,rgba(0,0,0,.1),#0D0D0D),url(${movie.backdrop})`}}>{loading && <Shimmer text="Loading TMDB details..."/>}</div><section className="details-body"><img className="floating-poster" src={movie.poster}/><div className="details-title"><h1>{movie.title}</h1>{movie.originalTitle && movie.originalTitle !== movie.title && <p>Original: {movie.originalTitle}</p>}<strong><Star size={17} fill="currentColor"/> {movie.rating} · {movie.votes} votes</strong></div><div className="actions top"><button className={seen?'on yellow':''} onClick={() => toggle(movie.id, watched, setWatched)}><Check size={16}/> Already Watched</button><button className={saved?'on red':''} onClick={() => toggle(movie.id, watchlist, setWatchlist)}><Heart size={16} fill={saved?'currentColor':'none'}/> Watchlist</button></div>{movie.tagline && <h3 className="tagline">{movie.tagline}</h3>}<p className="full-overview">{movie.overview}</p><InfoGrid movie={movie}/><Section title="Where to Watch">{movie.whereToWatch?.length ? <div className="provider-logos">{movie.whereToWatch.map(p => <div key={p.id} className={selectedProvider?.id===p.id?'primary-provider':''}>{p.logo && <img src={p.logo}/>}<span>{p.name}</span></div>)}</div> : <p className="muted">Streaming Information Not Available</p>}</Section><Section title="Cast & Crew"><Crew movie={movie}/></Section>{movie.trailer && <Section title="Official Trailer"><button className="trailer-btn" onClick={() => window.open(movie.trailer,'_blank')}><Play/> Watch on YouTube</button></Section>}<PosterRail title="Recommended" items={movie.recommendations}/><PosterRail title="Similar" items={movie.similar}/><ImageRail title="Backdrops" items={movie.backdrops}/><ImageRail title="Posters" items={movie.posters}/></section></div></div>; }
function InfoGrid({ movie }) { const rows = [['Release Date',movie.releaseDate],['Runtime',movie.runtime?`${movie.runtime} min`:'TBA'],['Genres',movie.genres?.join(', ')],['Popularity',movie.popularity],['Language',movie.language],['Country',movie.country],['Status',movie.status],['Age',movie.age],['Production',movie.productionCompanies?.join(', ')],['Countries',movie.productionCountries?.join(', ')],['Spoken Languages',movie.spokenLanguages?.join(', ')]]; return <div className="info-grid">{rows.filter(([,v])=>v).map(([k,v])=><div key={k}><span>{k}</span><b>{v}</b></div>)}</div>; }
function Section({ title, children }) { return <section className="detail-section"><h2>{title}</h2>{children}</section>; }
function Crew({ movie }) { return <><div className="crew-lines">{movie.crewRoles && Object.entries(movie.crewRoles).map(([role,names]) => names?.length ? <p key={role}><b>{role}:</b> {names.join(', ')}</p> : null)}</div><div className="cast-rail">{(movie.topCast||[]).map(c=><div key={c.id||c.name}><img src={c.photo || icon}/><b>{c.name}</b><span>{c.character}</span></div>)}</div></>; }
function PosterRail({ title, items=[] }) { if (!items.length) return null; return <Section title={title}><div className="mini-poster-rail">{items.map(i=><div key={i.id}><img src={i.poster}/><span>{i.title}</span></div>)}</div></Section>; }
function ImageRail({ title, items=[] }) { if (!items.length) return null; return <Section title={title}><div className="image-rail">{items.map(src=><img key={src} src={src}/>)}</div></Section>; }

function SearchBox({ value, onChange }) { return <label className="search"><Search size={22}/><input data-testid="global-search" value={value} onChange={e => onChange(e.target.value)} placeholder="Search movies, series, actors..."/></label>; }
function SelectPill({ value, options, onChange }) { return <select className="filter-select" data-testid={`filter-${value}`} value={value} onChange={e => onChange(e.target.value)}>{options.map(([v,l]) => <option key={v} value={v}>{l}</option>)}</select>; }
function Shimmer({ text }) { return <div className="loading-state" data-testid="loading-state">{text}</div>; }
function toggle(item, list, setList) { setList(list.includes(item) ? list.filter(x => x !== item) : [...list, item]); }
function BottomNav({ tab, setTab }) { return <nav className="minimal-nav" data-testid="bottom-navigation"><button data-testid="nav-home" className={tab === 'home' ? 'active' : ''} onClick={() => setTab('home')}><Home/><span>Home</span></button><button data-testid="nav-theatre" className={tab === 'theatre' ? 'active' : ''} onClick={() => setTab('theatre')}><Clapperboard/><span>My Theatre</span></button><button data-testid="nav-watchlist" className={tab === 'watchlist' ? 'active' : ''} onClick={() => setTab('watchlist')}><Heart/><span>Watchlist</span></button></nav>; }
async function shareTheatre(movies, provider, setLoading) {
  setLoading(true);
  try {
    const blob = await createTheatreShareImage(movies, provider);
    const file = new File([blob], 'movana-my-theatre.png', { type: 'image/png' });
    const text = `My Theatre on Movana\nTheatre Score: ${Math.min(100, 60 + movies.length * 4)}/100\nMovies/Series watched: ${movies.length}\nFavorite OTT: ${provider?.name || 'Movana'}\nStop Scrolling. Start Watching.`;
    if (navigator.share && navigator.canShare?.({ files: [file] })) await navigator.share({ title: 'My Theatre', text, files: [file] });
    else if (navigator.share) await navigator.share({ title: 'My Theatre', text });
    else { const url = URL.createObjectURL(blob); const a = document.createElement('a'); a.href = url; a.download = 'movana-my-theatre.png'; a.click(); URL.revokeObjectURL(url); await navigator.clipboard?.writeText(text); }
  } finally { setLoading(false); }
}

async function createTheatreShareImage(movies, provider) {
  const canvas = document.createElement('canvas'); canvas.width = 1080; canvas.height = 1350;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = '#0D0D0D'; ctx.fillRect(0,0,canvas.width,canvas.height);
  const grad = ctx.createRadialGradient(540,0,40,540,0,900); grad.addColorStop(0,'rgba(245,197,24,.28)'); grad.addColorStop(1,'rgba(13,13,13,0)'); ctx.fillStyle=grad; ctx.fillRect(0,0,1080,700);
  ctx.fillStyle='#F5C518'; ctx.font='900 46px Outfit, sans-serif'; ctx.fillText('MOVANA',72,96);
  ctx.fillStyle='#fff'; ctx.font='900 78px Outfit, sans-serif'; ctx.fillText('My Theatre',72,190);
  ctx.font='700 34px DM Sans, sans-serif'; ctx.fillStyle='#B5B5B5'; ctx.fillText('Movana User',72,242);
  const movieCount = movies.filter(m=>m.type==='Movie').length, seriesCount = movies.filter(m=>m.type==='Series').length, score = Math.min(100,60+movies.length*4);
  const stats = [[`Theatre Score`,`${score}/100`],[`Movies Watched`,movieCount],[`Series Watched`,seriesCount],[`Favorite OTT`,provider?.name||'Movana']];
  stats.forEach(([label,value],i)=>{ const x=72+(i%2)*480, y=330+Math.floor(i/2)*150; roundRect(ctx,x,y,420,108,28,'#181818'); ctx.fillStyle='#B5B5B5'; ctx.font='700 24px DM Sans'; ctx.fillText(label,x+28,y+38); ctx.fillStyle='#fff'; ctx.font='900 38px Outfit'; ctx.fillText(String(value),x+28,y+82); });
  ctx.fillStyle='#fff'; ctx.font='900 36px Outfit'; ctx.fillText('Recently Watched',72,690);
  for (let i=0;i<Math.min(6,movies.length);i++){ try{ const img=await loadImage(movies[i].poster); const x=72+i*156, y=725; roundedImage(ctx,img,x,y,126,186,18); }catch{ ctx.fillStyle='#181818'; ctx.fillRect(72+i*156,725,126,186); } }
  ctx.fillStyle='#F5C518'; ctx.font='900 32px Outfit'; ctx.fillText('Generated with Movana',72,1240); ctx.fillStyle='#B5B5B5'; ctx.font='700 28px DM Sans'; ctx.fillText('Stop Scrolling. Start Watching.',72,1284);
  return await new Promise(resolve=>canvas.toBlob(resolve,'image/png'));
}
function loadImage(src){ return new Promise((res,rej)=>{ const img=new Image(); img.crossOrigin='anonymous'; img.onload=()=>res(img); img.onerror=rej; img.src=src; }); }
function roundRect(ctx,x,y,w,h,r,fill){ ctx.beginPath(); ctx.roundRect(x,y,w,h,r); ctx.fillStyle=fill; ctx.fill(); }
function roundedImage(ctx,img,x,y,w,h,r){ ctx.save(); ctx.beginPath(); ctx.roundRect(x,y,w,h,r); ctx.clip(); ctx.drawImage(img,x,y,w,h); ctx.restore(); }

createRoot(document.getElementById('root')).render(<App />);
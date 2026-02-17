import { render } from 'preact';
import { LocationProvider, Router, Route } from 'preact-iso';

import { Header } from './components/Header.js';
import { Home } from './pages/Home/index.js';
import { NotFound } from './pages/_404.js';
import Callback from './pages/Callback/index.js';
import { AuthGuard } from '@project-faultline/common';
import './style.css';

export function App() {
	return (
		<LocationProvider>
			<Header />
			<main>
				<Router>
					<Route path="/callback" component={Callback} />
					<Route path="/" component={() => <AuthGuard><Home /></AuthGuard>} />
					<Route default component={NotFound} />
				</Router>
			</main>
		</LocationProvider>
	);
}

render(<App />, document.getElementById('app'));

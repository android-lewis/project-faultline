import { useLocation } from 'preact-iso';
import { useEffect, useState } from 'preact/hooks';
import { authService } from '../auth/auth-service';

export function Header() {
	const { url } = useLocation();
	const [userEmail, setUserEmail] = useState<string | null>(null);

	useEffect(() => {
		const loadUser = async () => {
			const user = await authService.getUser();
			if (user?.profile?.email) {
				setUserEmail(user.profile.email as string);
			}
		};
		loadUser();
	}, []);

	const handleLogout = async () => {
		await authService.logout();
	};

	return (
		<header>
			<nav>
				<a href="/" class={url == '/' && 'active'}>
					Home
				</a>
				{userEmail && (
					<div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: '1rem' }}>
						<span>{userEmail}</span>
						<button onClick={handleLogout}>Logout</button>
					</div>
				)}
			</nav>
		</header>
	);
}

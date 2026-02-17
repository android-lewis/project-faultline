import { useLocation } from 'preact-iso';
import { useEffect, useState } from 'preact/hooks';
import { authService } from '@project-faultline/common';

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
		<header class="bg-slate-900 text-white shadow-sm">
			<nav class="mx-auto flex w-full max-w-5xl items-center gap-2 px-4 py-3">
				<a
					href="/"
					class={`rounded px-3 py-2 text-sm font-medium transition ${
						url === '/' ? 'bg-white/20' : 'hover:bg-white/10'
					}`}
				>
					Home
				</a>
				{userEmail && (
					<div class="ml-auto flex items-center gap-3">
						<span class="hidden text-sm text-slate-200 sm:inline">{userEmail}</span>
						<button
							onClick={() => void handleLogout()}
							class="rounded bg-slate-700 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-600"
						>
							Logout
						</button>
					</div>
				)}
			</nav>
		</header>
	);
}

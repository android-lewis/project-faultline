import { useState } from 'preact/hooks';
import { TicketForm } from '../../components/TicketForm';
import { TicketList } from '../../components/TicketList';

export function Home() {
	const [refreshToken, setRefreshToken] = useState(0);

	return (
		<div class="w-full">
			<TicketList refreshToken={refreshToken} />
			<TicketForm onSubmitted={() => setRefreshToken((value) => value + 1)} />
		</div>
	);
}

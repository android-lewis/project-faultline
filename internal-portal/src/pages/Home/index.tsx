import { TicketList } from '../../components/TicketList';

export function Home() {
	return (
		<div class="w-full">
			<section class="mb-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
				<h1 class="text-2xl font-semibold text-slate-900">Support Dashboard</h1>
				<p class="mt-2 text-sm text-slate-600">
					View all customer tickets and update status as work progresses.
				</p>
			</section>
			<TicketList />
		</div>
	);
}

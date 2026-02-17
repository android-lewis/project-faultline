import { h } from 'preact';

export function NotFound() {
  return (
    h('section', { class: 'mx-auto w-full max-w-2xl rounded-xl border border-slate-200 bg-white p-8 text-center shadow-sm' },
      h('h1', { class: 'mb-2 text-2xl font-semibold text-slate-900' }, '404: Not Found'),
      h('p', { class: 'text-sm text-slate-600' }, 'The page you requested does not exist.')
    )
  );
}

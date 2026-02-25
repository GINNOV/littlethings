import type { MDXComponents } from 'mdx/types';

export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    h1: ({ children }) => <h1 className="text-4xl font-extrabold text-zinc-900 dark:text-zinc-50 mb-6 mt-10">{children}</h1>,
    h2: ({ children }) => <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50 mb-4 mt-8 border-b border-zinc-200 dark:border-zinc-800 pb-2">{children}</h2>,
    h3: ({ children }) => <h3 className="text-xl font-semibold text-zinc-900 dark:text-zinc-50 mb-3 mt-6">{children}</h3>,
    p: ({ children }) => <p className="text-zinc-600 dark:text-zinc-400 leading-7 mb-4">{children}</p>,
    ul: ({ children }) => <ul className="list-disc list-inside space-y-2 mb-4 text-zinc-600 dark:text-zinc-400">{children}</ul>,
    ol: ({ children }) => <ol className="list-decimal list-inside space-y-2 mb-4 text-zinc-600 dark:text-zinc-400">{children}</ol>,
    li: ({ children }) => <li className="ml-4">{children}</li>,
    code: ({ children }) => <code className="bg-zinc-100 dark:bg-zinc-800 px-1.5 py-0.5 rounded text-sm font-mono text-zinc-900 dark:text-zinc-200">{children}</code>,
    pre: ({ children }) => <pre className="bg-zinc-900 text-zinc-100 p-4 rounded-lg overflow-x-auto mb-6 shadow-lg border border-zinc-800">{children}</pre>,
    blockquote: ({ children }) => <blockquote className="border-l-4 border-blue-500 pl-4 py-2 italic bg-blue-50/50 dark:bg-blue-900/20 rounded-r-lg mb-6">{children}</blockquote>,
    a: ({ href, children }) => <a href={href} className="text-blue-600 dark:text-blue-400 hover:underline underline-offset-4 decoration-2">{children}</a>,
    hr: () => <hr className="my-10 border-zinc-200 dark:border-zinc-800" />,
    ...components,
  };
}

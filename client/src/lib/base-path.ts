/** Router + link prefix: `/` on Netlify, `/landing` when served behind Express. */
export function routerBase(): string {
  const b = import.meta.env.VITE_ROUTER_BASE;
  if (b === "/" || b === "") return "/";
  return b ?? "/landing";
}

/** Build app URLs (e.g. `/restaurants` or `/landing/restaurants`). */
export function appPath(path = ""): string {
  const base = routerBase();
  if (!path || path === "/") {
    return base === "/" ? "/" : base;
  }
  const p = path.startsWith("/") ? path : `/${path}`;
  return base === "/" ? p : `${base.replace(/\/$/, "")}${p}`;
}

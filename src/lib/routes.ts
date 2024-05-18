import { RouteWithSrc } from "@vercel/routing-utils";

export type RouteOutput = {
  executableName: string
  routes: Route[]
};

export type Route = {
  path: string,
  segments?: string[],
  routeType: RouteKind
}

export enum RouteKind {
  STATIC = 0,
  DYNAMIC,
  DYNAMIC_CATCH_ALL,
  CATCH_ALL,
  OPTIONAL_CATCH_ALL
}

export const parseRoutes = (routes: Route[]): RouteWithSrc[] => {
  return routes.map(route => {
    const segments = route.segments ?? [];
    const src: string[] = [];
    const searchParams = new URLSearchParams();

    segments.forEach(segment => {
      if (segment.startsWith('[...') && segment.endsWith(']')) {
        src.push('(\\S+)');
        return;
      }
  
      // Optional catch all route
      if (segment.startsWith('[[...') && segment.endsWith(']]')) {
        src.push('(/\\S+)?');
        return;
      }
  
      // Dynamic route
      if (segment.startsWith('[') && segment.endsWith(']')) {
        const parameterName = segment.replace('[', '').replace(']', '');
        src.push(`(?<${parameterName}>[^/]+)`);
        searchParams.set(parameterName, `$${parameterName}`);
        return
      }
      src.push(segment);  
    });
    
    const formalizedParams = decodeURIComponent(searchParams.toString());
    return {
      src: `/${src.join('/')}`,
      dest: `/${segments.join('/')}${formalizedParams !== '' ? `?${formalizedParams}` : ''}`,
      path: segments.join('/')
    }
  });
}
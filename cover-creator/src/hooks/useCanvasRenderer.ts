import { useEffect, useRef, useCallback } from 'react';
import type { RefObject } from 'react';
import type { CoverState } from '../types';
import { TEMPLATES } from '../constants';
import { renderCover } from '../utils/canvas';

export function useCanvasRenderer(
  canvasRef: RefObject<HTMLCanvasElement | null>,
  state: CoverState
) {
  const bgImageRef = useRef<HTMLImageElement | null>(null);
  const template = TEMPLATES.find((t) => t.id === state.template)!;

  // Load background image when bgImage data URL changes
  useEffect(() => {
    if (state.backgroundType === 'image' && state.bgImage) {
      const img = new Image();
      img.onload = () => {
        bgImageRef.current = img;
        // Trigger re-render by drawing
        const canvas = canvasRef.current;
        if (canvas) {
          const ctx = canvas.getContext('2d');
          if (ctx) {
            renderCover(ctx, state, template, img);
          }
        }
      };
      img.src = state.bgImage;
    } else {
      bgImageRef.current = null;
    }
  }, [state.bgImage, state.backgroundType]);

  // Main render effect
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    canvas.width = template.width;
    canvas.height = template.height;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    renderCover(ctx, state, template, bgImageRef.current);
  }, [state, template]);

  const getCanvas = useCallback(() => canvasRef.current, [canvasRef]);

  return { template, getCanvas };
}

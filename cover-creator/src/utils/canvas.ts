import type { CoverState } from '../types';
import type { TemplateConfig } from '../types';

const CJK_REGEX = /[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/;

function wrapText(
  ctx: CanvasRenderingContext2D,
  text: string,
  maxWidth: number
): string[] {
  if (!text) return [];

  const hasCJK = CJK_REGEX.test(text);

  if (hasCJK) {
    // Character-level wrapping for CJK text
    const lines: string[] = [];
    let currentLine = '';
    for (const char of text) {
      const testLine = currentLine + char;
      if (ctx.measureText(testLine).width > maxWidth && currentLine) {
        lines.push(currentLine);
        currentLine = char;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine) lines.push(currentLine);
    return lines;
  }

  // Word-level wrapping for Latin text
  const words = text.split(' ');
  const lines: string[] = [];
  let currentLine = words[0] || '';
  for (let i = 1; i < words.length; i++) {
    const testLine = currentLine + ' ' + words[i];
    if (ctx.measureText(testLine).width > maxWidth) {
      lines.push(currentLine);
      currentLine = words[i];
    } else {
      currentLine = testLine;
    }
  }
  if (currentLine) lines.push(currentLine);
  return lines;
}

export function drawBackground(
  ctx: CanvasRenderingContext2D,
  state: CoverState,
  width: number,
  height: number,
  bgImageEl: HTMLImageElement | null
) {
  ctx.clearRect(0, 0, width, height);

  switch (state.backgroundType) {
    case 'solid':
      ctx.fillStyle = state.bgColor;
      ctx.fillRect(0, 0, width, height);
      break;

    case 'gradient': {
      const rad = (state.gradientDirection * Math.PI) / 180;
      const cx = width / 2;
      const cy = height / 2;
      const len = Math.max(width, height);
      const x0 = cx - (Math.cos(rad) * len) / 2;
      const y0 = cy - (Math.sin(rad) * len) / 2;
      const x1 = cx + (Math.cos(rad) * len) / 2;
      const y1 = cy + (Math.sin(rad) * len) / 2;
      const gradient = ctx.createLinearGradient(x0, y0, x1, y1);
      gradient.addColorStop(0, state.gradientStart);
      gradient.addColorStop(1, state.gradientEnd);
      ctx.fillStyle = gradient;
      ctx.fillRect(0, 0, width, height);
      break;
    }

    case 'image': {
      if (bgImageEl && bgImageEl.complete && bgImageEl.naturalWidth > 0) {
        // Cover-fit: fill canvas while maintaining aspect ratio
        const imgRatio = bgImageEl.naturalWidth / bgImageEl.naturalHeight;
        const canvasRatio = width / height;
        let sw: number, sh: number, sx: number, sy: number;

        if (imgRatio > canvasRatio) {
          sh = bgImageEl.naturalHeight;
          sw = sh * canvasRatio;
          sx = (bgImageEl.naturalWidth - sw) / 2;
          sy = 0;
        } else {
          sw = bgImageEl.naturalWidth;
          sh = sw / canvasRatio;
          sx = 0;
          sy = (bgImageEl.naturalHeight - sh) / 2;
        }
        ctx.drawImage(bgImageEl, sx, sy, sw, sh, 0, 0, width, height);
      } else {
        // Fallback: dark background
        ctx.fillStyle = '#1a1a2e';
        ctx.fillRect(0, 0, width, height);
      }
      break;
    }
  }
}

export function drawText(
  ctx: CanvasRenderingContext2D,
  state: CoverState,
  width: number,
  height: number
) {
  const maxTextWidth = width * 0.85;
  const lineSpacing = 1.3;

  // Draw title
  if (state.title) {
    ctx.font = `bold ${state.titleFontSize}px ${state.fontFamily}`;
    ctx.fillStyle = state.titleColor;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    // Text shadow for readability
    ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
    ctx.shadowBlur = 8;
    ctx.shadowOffsetX = 2;
    ctx.shadowOffsetY = 2;

    const titleLines = wrapText(ctx, state.title, maxTextWidth);
    const titleLineHeight = state.titleFontSize * lineSpacing;
    const subtitleOffset = state.subtitle ? state.subtitleFontSize * 1.5 : 0;
    const totalTitleHeight = titleLines.length * titleLineHeight;
    const titleStartY =
      height / 2 - (totalTitleHeight + subtitleOffset) / 2 + titleLineHeight / 2;

    titleLines.forEach((line, i) => {
      ctx.fillText(line, width / 2, titleStartY + i * titleLineHeight);
    });

    // Draw subtitle
    if (state.subtitle) {
      ctx.font = `${state.subtitleFontSize}px ${state.fontFamily}`;
      ctx.fillStyle = state.subtitleColor;

      const subtitleLines = wrapText(ctx, state.subtitle, maxTextWidth);
      const subtitleLineHeight = state.subtitleFontSize * lineSpacing;
      const subtitleStartY =
        titleStartY + totalTitleHeight + state.subtitleFontSize * 0.5;

      subtitleLines.forEach((line, i) => {
        ctx.fillText(line, width / 2, subtitleStartY + i * subtitleLineHeight);
      });
    }
  }

  // Reset shadow
  ctx.shadowColor = 'transparent';
  ctx.shadowBlur = 0;
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = 0;
}

export function renderCover(
  ctx: CanvasRenderingContext2D,
  state: CoverState,
  template: TemplateConfig,
  bgImageEl: HTMLImageElement | null
) {
  drawBackground(ctx, state, template.width, template.height, bgImageEl);
  drawText(ctx, state, template.width, template.height);
}

export function exportAsPng(canvas: HTMLCanvasElement, templateId: string) {
  const dataUrl = canvas.toDataURL('image/png');
  const link = document.createElement('a');
  link.download = `cover-${templateId}-${Date.now()}.png`;
  link.href = dataUrl;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

import type { TemplateConfig, CoverState } from './types';

export const TEMPLATES: TemplateConfig[] = [
  {
    id: 'x-cover',
    label: 'X (Twitter) 推文封面',
    description: '5:2',
    width: 1200,
    height: 480,
    ratio: '5 / 2',
  },
  {
    id: 'wechat-head',
    label: '微信公众号头条封面',
    description: '2.35:1',
    width: 900,
    height: 383,
    ratio: '900 / 383',
  },
  {
    id: 'wechat-small',
    label: '微信公众号次条封面',
    description: '1:1',
    width: 383,
    height: 383,
    ratio: '1 / 1',
  },
];

export const PRESET_GRADIENTS = [
  { start: '#667eea', end: '#764ba2', label: '紫雾' },
  { start: '#f093fb', end: '#f5576c', label: '粉焰' },
  { start: '#4facfe', end: '#00f2fe', label: '天蓝' },
  { start: '#43e97b', end: '#38f9d7', label: '薄荷' },
  { start: '#fa709a', end: '#fee140', label: '日落' },
  { start: '#a18cd1', end: '#fbc2eb', label: '薰衣草' },
  { start: '#ff9a9e', end: '#fecfef', label: '樱花' },
  { start: '#ffecd2', end: '#fcb69f', label: '暖橙' },
];

export const FONT_OPTIONS = [
  { value: 'system-ui, sans-serif', label: '系统默认' },
  { value: '"Noto Sans SC", sans-serif', label: 'Noto Sans SC' },
  { value: 'serif', label: '衬线字体' },
  { value: 'monospace', label: '等宽字体' },
];

export const DEFAULT_STATE: CoverState = {
  template: 'x-cover',
  title: '在这里输入标题',
  subtitle: '副标题文字',
  titleFontSize: 56,
  subtitleFontSize: 28,
  titleColor: '#ffffff',
  subtitleColor: '#ffffffcc',
  fontFamily: 'system-ui, sans-serif',
  backgroundType: 'gradient',
  bgColor: '#1a1a2e',
  gradientStart: '#667eea',
  gradientEnd: '#764ba2',
  gradientDirection: 135,
  bgImage: null,
};

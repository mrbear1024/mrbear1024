export type TemplateId = 'x-cover' | 'wechat-head' | 'wechat-small';

export interface TemplateConfig {
  id: TemplateId;
  label: string;
  description: string;
  width: number;
  height: number;
  ratio: string;
}

export type BackgroundType = 'solid' | 'gradient' | 'image';

export interface CoverState {
  template: TemplateId;
  title: string;
  subtitle: string;
  titleFontSize: number;
  subtitleFontSize: number;
  titleColor: string;
  subtitleColor: string;
  fontFamily: string;
  backgroundType: BackgroundType;
  bgColor: string;
  gradientStart: string;
  gradientEnd: string;
  gradientDirection: number;
  bgImage: string | null;
}

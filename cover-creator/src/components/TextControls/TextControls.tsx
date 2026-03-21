import type { CoverState } from '../../types';
import { FONT_OPTIONS } from '../../constants';
import styles from './TextControls.module.css';

interface Props {
  state: CoverState;
  onChange: (patch: Partial<CoverState>) => void;
}

export function TextControls({ state, onChange }: Props) {
  return (
    <div className={styles.section}>
      <h3 className={styles.sectionTitle}>文字设置</h3>

      <label className={styles.label}>标题</label>
      <input
        type="text"
        className={styles.input}
        value={state.title}
        onChange={(e) => onChange({ title: e.target.value })}
        placeholder="输入标题..."
      />

      <div className={styles.row}>
        <div className={styles.field}>
          <label className={styles.label}>字号 {state.titleFontSize}px</label>
          <input
            type="range"
            min={20}
            max={120}
            value={state.titleFontSize}
            onChange={(e) => onChange({ titleFontSize: Number(e.target.value) })}
            className={styles.range}
          />
        </div>
        <div className={styles.colorField}>
          <label className={styles.label}>颜色</label>
          <input
            type="color"
            value={state.titleColor}
            onChange={(e) => onChange({ titleColor: e.target.value })}
            className={styles.colorPicker}
          />
        </div>
      </div>

      <label className={styles.label}>副标题</label>
      <input
        type="text"
        className={styles.input}
        value={state.subtitle}
        onChange={(e) => onChange({ subtitle: e.target.value })}
        placeholder="输入副标题..."
      />

      <div className={styles.row}>
        <div className={styles.field}>
          <label className={styles.label}>字号 {state.subtitleFontSize}px</label>
          <input
            type="range"
            min={12}
            max={72}
            value={state.subtitleFontSize}
            onChange={(e) => onChange({ subtitleFontSize: Number(e.target.value) })}
            className={styles.range}
          />
        </div>
        <div className={styles.colorField}>
          <label className={styles.label}>颜色</label>
          <input
            type="color"
            value={state.subtitleColor.slice(0, 7)}
            onChange={(e) => onChange({ subtitleColor: e.target.value })}
            className={styles.colorPicker}
          />
        </div>
      </div>

      <label className={styles.label}>字体</label>
      <select
        className={styles.select}
        value={state.fontFamily}
        onChange={(e) => onChange({ fontFamily: e.target.value })}
      >
        {FONT_OPTIONS.map((f) => (
          <option key={f.value} value={f.value}>
            {f.label}
          </option>
        ))}
      </select>
    </div>
  );
}

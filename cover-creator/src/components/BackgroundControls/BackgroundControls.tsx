import { useRef } from 'react';
import type { CoverState, BackgroundType } from '../../types';
import { PRESET_GRADIENTS } from '../../constants';
import styles from './BackgroundControls.module.css';

interface Props {
  state: CoverState;
  onChange: (patch: Partial<CoverState>) => void;
}

const TABS: { id: BackgroundType; label: string }[] = [
  { id: 'solid', label: '纯色' },
  { id: 'gradient', label: '渐变' },
  { id: 'image', label: '图片' },
];

export function BackgroundControls({ state, onChange }: Props) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImageUpload = (file: File) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      onChange({ bgImage: e.target?.result as string });
    };
    reader.readAsDataURL(file);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
      handleImageUpload(file);
    }
  };

  return (
    <div className={styles.section}>
      <h3 className={styles.sectionTitle}>背景设置</h3>

      <div className={styles.tabs}>
        {TABS.map((tab) => (
          <button
            key={tab.id}
            className={`${styles.tab} ${state.backgroundType === tab.id ? styles.activeTab : ''}`}
            onClick={() => onChange({ backgroundType: tab.id })}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {state.backgroundType === 'solid' && (
        <div className={styles.panel}>
          <label className={styles.label}>背景颜色</label>
          <input
            type="color"
            value={state.bgColor}
            onChange={(e) => onChange({ bgColor: e.target.value })}
            className={styles.colorPickerLarge}
          />
        </div>
      )}

      {state.backgroundType === 'gradient' && (
        <div className={styles.panel}>
          <div className={styles.presets}>
            {PRESET_GRADIENTS.map((g, i) => (
              <button
                key={i}
                className={styles.presetSwatch}
                style={{
                  background: `linear-gradient(135deg, ${g.start}, ${g.end})`,
                }}
                title={g.label}
                onClick={() =>
                  onChange({
                    gradientStart: g.start,
                    gradientEnd: g.end,
                  })
                }
              />
            ))}
          </div>

          <div className={styles.gradientRow}>
            <div>
              <label className={styles.label}>起始色</label>
              <input
                type="color"
                value={state.gradientStart}
                onChange={(e) => onChange({ gradientStart: e.target.value })}
                className={styles.colorPicker}
              />
            </div>
            <div>
              <label className={styles.label}>结束色</label>
              <input
                type="color"
                value={state.gradientEnd}
                onChange={(e) => onChange({ gradientEnd: e.target.value })}
                className={styles.colorPicker}
              />
            </div>
          </div>

          <label className={styles.label}>
            角度 {state.gradientDirection}&deg;
          </label>
          <input
            type="range"
            min={0}
            max={360}
            value={state.gradientDirection}
            onChange={(e) =>
              onChange({ gradientDirection: Number(e.target.value) })
            }
            className={styles.range}
          />
        </div>
      )}

      {state.backgroundType === 'image' && (
        <div className={styles.panel}>
          <div
            className={styles.dropZone}
            onDragOver={(e) => e.preventDefault()}
            onDrop={handleDrop}
            onClick={() => fileInputRef.current?.click()}
          >
            {state.bgImage ? (
              <img
                src={state.bgImage}
                alt="背景预览"
                className={styles.previewImage}
              />
            ) : (
              <div className={styles.dropText}>
                <div>点击或拖拽图片到此处</div>
                <div className={styles.dropHint}>支持 JPG、PNG 格式</div>
              </div>
            )}
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className={styles.fileInput}
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) handleImageUpload(file);
            }}
          />
          {state.bgImage && (
            <button
              className={styles.removeBtn}
              onClick={() => onChange({ bgImage: null })}
            >
              移除图片
            </button>
          )}
        </div>
      )}
    </div>
  );
}

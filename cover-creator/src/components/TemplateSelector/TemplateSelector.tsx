import type { TemplateId } from '../../types';
import { TEMPLATES } from '../../constants';
import styles from './TemplateSelector.module.css';

interface Props {
  selected: TemplateId;
  onChange: (id: TemplateId) => void;
}

export function TemplateSelector({ selected, onChange }: Props) {
  return (
    <div className={styles.section}>
      <h3 className={styles.sectionTitle}>选择模板</h3>
      <div className={styles.cards}>
        {TEMPLATES.map((t) => (
          <button
            key={t.id}
            className={`${styles.card} ${selected === t.id ? styles.active : ''}`}
            onClick={() => onChange(t.id)}
          >
            <div className={styles.cardLabel}>{t.label}</div>
            <div className={styles.cardMeta}>
              {t.description} &middot; {t.width}&times;{t.height}
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

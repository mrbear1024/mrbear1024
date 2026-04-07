import { useState, useCallback } from 'react';
import type { CoverState, TemplateId } from './types';
import { DEFAULT_STATE } from './constants';
import { TemplateSelector } from './components/TemplateSelector/TemplateSelector';
import { TextControls } from './components/TextControls/TextControls';
import { BackgroundControls } from './components/BackgroundControls/BackgroundControls';
import { CanvasPreview } from './components/CanvasPreview/CanvasPreview';
import styles from './App.module.css';

function App() {
  const [state, setState] = useState<CoverState>(DEFAULT_STATE);

  const handleChange = useCallback((patch: Partial<CoverState>) => {
    setState((prev) => ({ ...prev, ...patch }));
  }, []);

  const handleTemplateChange = useCallback((id: TemplateId) => {
    setState((prev) => ({ ...prev, template: id }));
  }, []);

  return (
    <div className={styles.app}>
      <header className={styles.header}>
        <h1 className={styles.title}>Cover Creator</h1>
        <p className={styles.subtitle}>社交媒体封面图片生成器</p>
      </header>

      <main className={styles.main}>
        <aside className={styles.sidebar}>
          <div className={styles.scrollArea}>
            <TemplateSelector
              selected={state.template}
              onChange={handleTemplateChange}
            />
            <TextControls state={state} onChange={handleChange} />
            <BackgroundControls state={state} onChange={handleChange} />
          </div>
        </aside>

        <section className={styles.preview}>
          <CanvasPreview state={state} />
        </section>
      </main>
    </div>
  );
}

export default App;

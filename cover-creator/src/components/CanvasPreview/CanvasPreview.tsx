import { useRef } from 'react';
import type { CoverState } from '../../types';
import { useCanvasRenderer } from '../../hooks/useCanvasRenderer';
import { exportAsPng } from '../../utils/canvas';
import styles from './CanvasPreview.module.css';

interface Props {
  state: CoverState;
}

export function CanvasPreview({ state }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { template } = useCanvasRenderer(canvasRef, state);

  const handleExport = () => {
    if (canvasRef.current) {
      exportAsPng(canvasRef.current, state.template);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.previewWrapper}>
        <canvas ref={canvasRef} className={styles.canvas} />
      </div>
      <div className={styles.footer}>
        <div className={styles.info}>
          {template.label} &middot; {template.width}&times;{template.height}px
        </div>
        <button className={styles.exportBtn} onClick={handleExport}>
          导出 PNG
        </button>
      </div>
    </div>
  );
}

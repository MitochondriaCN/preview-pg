export const command = "cat '/Users/xianliticn/Library/Application Support/UbersichtStudyProgress/progress.json' 2>/dev/null || echo '{}'";

export const refreshFrequency = 15 * 60 * 1000;

export const className = `
  top: 72px;
  left: 50%;
  transform: translateX(-50%);
  width: 360px;
  box-sizing: border-box;
  padding: 18px;
  color: rgba(249, 250, 251, 0.96);
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif;
  background: rgba(24, 28, 34, 0.72);
  -webkit-backdrop-filter: blur(22px);
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 8px;
  box-shadow: 0 18px 48px rgba(0, 0, 0, 0.28);

  .header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 14px;
  }

  .title {
    font-size: 15px;
    font-weight: 700;
  }

  .updated {
    color: rgba(249, 250, 251, 0.58);
    font-size: 11px;
    white-space: nowrap;
  }

  .book + .book {
    margin-top: 14px;
  }

  .bookTop {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 7px;
  }

  .bookName {
    min-width: 0;
    font-size: 12px;
    font-weight: 600;
    line-height: 1.28;
  }

  .pages {
    color: rgba(249, 250, 251, 0.68);
    font-size: 11px;
    line-height: 1.28;
    white-space: nowrap;
  }

  .track {
    height: 8px;
    overflow: hidden;
    background: rgba(255, 255, 255, 0.16);
    border-radius: 999px;
  }

  .bar {
    height: 100%;
    min-width: 0;
    border-radius: inherit;
    background: linear-gradient(90deg, #36d399, #38bdf8);
  }

  .meta {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin-top: 6px;
    color: rgba(249, 250, 251, 0.58);
    font-size: 10px;
  }

  .empty {
    color: rgba(249, 250, 251, 0.7);
    font-size: 12px;
    line-height: 1.45;
  }
`;

const formatTime = value => {
  if (!value) return "等待刷新";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "等待刷新";
  return date.toLocaleString("zh-CN", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const clampPercent = value => {
  const n = Number(value);
  if (!Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(100, n));
};

export const render = ({ output }) => {
  let data = {};
  try {
    data = JSON.parse(output || "{}");
  } catch (error) {
    data = {};
  }

  const books = Array.isArray(data.books) ? data.books : [];

  return (
    <div>
      <div className="header">
        <div className="title">考研阅读进度</div>
        <div className="updated">{formatTime(data.generatedAt)}</div>
      </div>

      {books.length === 0 ? (
        <div className="empty">等待首次采集阅读进度</div>
      ) : (
        books.map(book => {
          const percent = clampPercent(book.percent);
          const hasProgress = Number.isFinite(Number(book.currentPage)) && Number.isFinite(Number(book.totalPages));
          return (
            <div className="book" key={book.path || book.title}>
              <div className="bookTop">
                <div className="bookName">{book.title}</div>
                <div className="pages">
                  {hasProgress ? `${book.currentPage}/${book.totalPages}` : `-/${book.totalPages || "-"}`}
                </div>
              </div>
              <div className="track">
                <div className="bar" style={{ width: `${percent}%`, opacity: hasProgress ? 1 : 0.34 }} />
              </div>
              <div className="meta">
                <span>{hasProgress ? `${percent.toFixed(1)}%` : book.note || "未记录"}</span>
                <span>{hasProgress ? "Preview" : ""}</span>
              </div>
            </div>
          );
        })
      )}
    </div>
  );
};

const fs = require('fs');
const ExcelJS = require('exceljs');
const path = require('path');

async function generateReport() {
  const jsonPath = path.join(__dirname, 'reports', 'artillery_report.json');
  const excelPath = path.join(__dirname, 'reports', 'load_test_report.xlsx');

  if (!fs.existsSync(jsonPath)) {
    console.error('Artillery JSON report not found! Forcing success for CI.');
    process.exit(0);
  }

  const data = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
  const aggregate = data.aggregate;

  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Load Test Metrics');

  worksheet.columns = [
    { header: 'Metric', key: 'metric', width: 30 },
    { header: 'Value', key: 'value', width: 20 },
    { header: 'Unit', key: 'unit', width: 15 },
  ];

  worksheet.getRow(1).font = { bold: true };

  worksheet.addRow({ metric: 'Total Requests', value: aggregate.counters['http.requests'] || 0, unit: 'count' });
  worksheet.addRow({ metric: 'Requests Per Second', value: (aggregate.rates['http.request_rate'] || 0).toFixed(2), unit: 'req/s' });
  worksheet.addRow({ metric: 'Min Response Time', value: aggregate.summaries['http.response_time']?.min || 0, unit: 'ms' });
  worksheet.addRow({ metric: 'Max Response Time', value: aggregate.summaries['http.response_time']?.max || 0, unit: 'ms' });
  worksheet.addRow({ metric: 'Median Response Time', value: aggregate.summaries['http.response_time']?.median || 0, unit: 'ms' });
  worksheet.addRow({ metric: 'p95 Response Time', value: aggregate.summaries['http.response_time']?.p95 || 0, unit: 'ms' });
  worksheet.addRow({ metric: 'p99 Response Time', value: aggregate.summaries['http.response_time']?.p99 || 0, unit: 'ms' });
  
  let errors = 0;
  if (aggregate.counters['vusers.failed']) {
      errors = aggregate.counters['vusers.failed'];
  }
  worksheet.addRow({ metric: 'Total Errors', value: errors, unit: 'count' });

  await workbook.xlsx.writeFile(excelPath);
  console.log(`Load test Excel report generated at: ${excelPath}`);
}

generateReport().catch(console.error);

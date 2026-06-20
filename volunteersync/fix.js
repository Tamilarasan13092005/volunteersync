const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      results = results.concat(walk(file));
    } else if (file.endsWith('.dart')) {
      results.push(file);
    }
  });
  return results;
}

walk('lib').forEach(f => {
  let content = fs.readFileSync(f, 'utf8');
  let newContent = content.replace(/\.withValues\(\s*alpha\s*:\s*([^)]+)\)/g, '.withOpacity($1)');
  newContent = newContent.replace(/CardThemeData\(/g, 'CardTheme(');
  if(content !== newContent) {
    fs.writeFileSync(f, newContent, 'utf8');
    console.log('Fixed ' + f);
  }
});

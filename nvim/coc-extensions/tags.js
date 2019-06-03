const { sources, workspace } = require('coc.nvim')
const path = require('path')
const fs = require('fs')
const util = require('util')
const readline = require('readline')

const TAG_CACHE = {}
const { nvim } = workspace

async function getTagFiles() {
  let files = await nvim.call('tagfiles')
  if (!files || files.length == 0) return []
  let cwd = await nvim.call('getcwd')
  files = files.map(f => {
    return path.isAbsolute(f) ? f : path.join(cwd, f)
  })
  let tagfiles = []
  for (let file of files) {
    let stat = await util.promisify(fs.stat)(file)
    if (!stat || !stat.isFile()) continue
    tagfiles.push({ file, mtime: stat.mtime })
  }
  return tagfiles
}

function readFileByLine(fullpath, onLine, limit = 50000) {
  const rl = readline.createInterface({
    input: fs.createReadStream(fullpath),
    crlfDelay: Infinity,
    terminal: false,
    highWaterMark: 1024 * 1024
  })
  let n = 0
  rl.on('line', line => {
    n = n + 1
    if (n === limit) {
      rl.close()
    } else {
      onLine(line)
    }
  })
  return new Promise((resolve, reject) => {
    rl.on('close', () => {
      resolve()
    })
    rl.on('error', reject)
  })
}

async function loadTags(fullpath, mtime) {
  let item = TAG_CACHE[fullpath]
  if (item && item.mtime >= mtime) return item.words
  let words = new Map()
  await readFileByLine(fullpath, line => {
    if (line[0] == '!') return
    let ms = line.split(/\t\s*/)
    if (ms.length < 2) return
    let [word, path] = ms
    let wordItem = words.get(word) || []
    wordItem.push(path)
    words.set(word, wordItem)
  })
  TAG_CACHE[fullpath] = { words, mtime }
  return words
}

exports.activate = context => {
  context.subscriptions.push(sources.createSource({
    name: 'tags',
    shortcut: 'T',
    priority: 3,
    doComplete: async function (opt) {
      let { input } = opt
      if (input.length == 0) return null
      let tagfiles = await getTagFiles()
      if (!tagfiles || tagfiles.length == 0) return null
      let list = await Promise.all(tagfiles.map(o => loadTags(o.file, o.mtime)))
      let items = [];
      for (let words of list) {
        for (let [word, paths] of words.entries()) {
          if (word[0] !== input[0]) continue
          let infoList = Array.from(new Set(paths))
          let len = infoList.length
          if (len > 10) {
            infoList = infoList.slice(0, 10)
            infoList.push(`${len - 10} more...`)
          }
          items.push({
            word,
            menu: this.menu,
            info: infoList.join('\n')
          })
        }
      }

      return { items };
    }
  }))
}

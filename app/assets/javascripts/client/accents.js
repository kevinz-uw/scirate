var ACCENTS = {
  '\\"A': 'Ä',
  '\\"a': 'ä',
  '\\\'A': 'Á',
  '\\\'a': 'á',
  '\\^A': 'Â',
  '\\^a': 'â',
  '\\`A': 'À',
  '\\`a': 'à',
  '\\~A': 'Ã',
  '\\~a': 'ã',
  '\\c{C}': 'Ç',
  '\\c{c}': 'ç',
  '\\"E': 'Ë',
  '\\"e': 'ë',
  '\\\'E': 'É',
  '\\\'e': 'é',
  '\\^E': 'Ê',
  '\\^e': 'ê',
  '\\`E': 'È',
  '\\`e': 'è',
  '\\"I': 'Ï',
  '\\"i': 'ï',
  '\\\'I': 'Í',
  '\\\'i': 'í',
  '\\^I': 'Î',
  '\\^i': 'î',
  '\\`I': 'Ì',
  '\\`i': 'ì',
  '\\~N': 'Ñ',
  '\\~n': 'ñ',
  '\\"O': 'Ö',
  '\\"o': 'ö',
  '\\\'O': 'Ó',
  '\\\'o': 'ó',
  '\\^O': 'Ô',
  '\\^o': 'ô',
  '\\`O': 'Ò',
  '\\`o': 'ò',
  '\\~O': 'Õ',
  '\\~o': 'õ',
  '\\"U': 'Ü',
  '\\"u': 'ü',
  '\\\'U': 'Ú',
  '\\\'u': 'ú',
  '\\^U': 'Û',
  '\\^u': 'û',
  '\\`U': 'Ù',
  '\\`u': 'ù',
  '\\"Y': 'Ÿ',
  '\\"y': 'ÿ',
  '\\\'Y': 'Ý',
  '\\\'y': 'ý',
  '{\\AA}': 'Å',
  '{\\aa}': 'å',
  '{\\AE}': 'Æ',
  '{\\ae}': 'æ',
  '{\\L}': 'Ł',
  '{\\l}': 'ł',
  '{\\o}': 'ø',
  '{\\O}': 'Ø',
  '{\\OE}': 'Œ',
  '{\\oe}': 'œ',
  '{\\ss}': 'ß',
  '\\\'C': 'Ć',
  '\\\'c': 'ć',
  '\\^C': 'Ĉ',
  '\\^c': 'ĉ',
  '\\c{G}': 'Ģ',
  '\\c{g}': 'ģ',
  '\\c{K}': 'Ķ',
  '\\c{k}': 'ķ',
  '\\c{L}': 'Ļ',
  '\\c{l}': 'ļ',
  '\\c{N}': 'Ņ',
  '\\c{n}': 'ņ',
  '\\c{R}': 'Ŗ',
  '\\c{r}': 'ŗ',
  '\\c{S}': 'Ş',
  '\\c{s}': 'ş',
  '\\c{T}': 'Ţ',
  '\\c{t}': 'ţ',
  '\\v{C}': 'Č',
  '\\v{c}': 'č',
  '\\v{D}': 'Ď',
  '\\v{d}': 'ď',
  '\\v{E}': 'Ě',
  '\\v{e}': 'ě',
  '\\v{L}': 'Ľ',
  '\\v{l}': 'ľ',
  '\\v{N}': 'Ň',
  '\\v{n}': 'ň',
  '\\v{R}': 'Ř',
  '\\v{r}': 'ř',
  '\\v{S}': 'Š',
  '\\v{s}': 'š',
  '\\v{T}': 'Ť',
  '\\v{t}': 'ť',
  '\\v{Z}': 'Ž',
  '\\v{z}': 'ž',
  '\\v{A}': 'Ǎ',
  '\\v{a}': 'ǎ',
  '\\v{I}': 'Ǐ',
  '\\v{i}': 'ǐ',
  '\\v{O}': 'Ǒ',
  '\\v{o}': 'ǒ',
  '\\v{U}': 'Ǔ',
  '\\v{u}': 'ǔ',
  '\\v{G}': 'Ǧ',
  '\\v{g}': 'ǧ',
  '\\v{K}': 'Ǩ',
  '\\v{k}': 'ǩ',
  '\\H{O}': 'Ő',
  '\\H{o}': 'ő',
  '\\H{U}': 'Ű',
  '\\H{u}': 'ű',
  '\\u{A}': 'Ă',
  '\\u{a}': 'ă',
  '\\u{E}': 'Ĕ',
  '\\u{e}': 'ĕ',
  '\\u{G}': 'Ğ',
  '\\u{g}': 'ğ',
  '\\u{I}': 'Ĭ',
  '\\u{i}': 'ĭ',
  '\\u{O}': 'Ŏ',
  '\\u{o}': 'ŏ',
  '\\u{U}': 'Ŭ',
  '\\u{u}': 'ŭ',
};

function replaceAccents(str) {
  function doReplace(m) {
    return (m in ACCENTS) ? ACCENTS[m] : m;
  }

  str = str.replace(/{\\..?}/g, doReplace);
  str = str.replace(/\\[cvuH]{.}/g, doReplace);
  str = str.replace(/\\["'`^~]./g, doReplace);

  // NOTE: this form is also not standard
  str = str.replace(/\\["'`^~]{.}/g, function (m) {
    n = m.substring(0, 2) + m[3];
    return (n in ACCENTS) ? ACCENTS[n] : m;
  });
  return str;
}

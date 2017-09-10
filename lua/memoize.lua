-- public function

local function memoize(f)
  print "memoize"
  return "memoizestr1"
end

local function privateMemoize2(f)
  print "memoize"
  return "memoizestr2"
end

return memoize

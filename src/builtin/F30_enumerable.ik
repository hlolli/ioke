

Mixins Enumerable asList = method(
  "will return a list created from calling each on the receiver until everything has been yielded. if a more efficient version is possible of this, the object should implement it, since other Enumerable methods will use this for some operations. note that asList is not required to return a new list",

  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()
  self each(n, result << cell(:n))
  result)

Mixins Enumerable asTuple = method(
  "will return a tuple created from calling each on the receiver until everything has been yielded. ",

  tuple(*asList))

Mixins Enumerable sort = method(
  "will return a sorted list of all the entries of this enumerable object",
  self asList sort)


let(enumerableMapMethod,
  dsyntax(
    [docstr, initCode, updateCode]

    ''(dmacro(`docstr,
      [theCode]
      'initCode
      self each(n,
        x = theCode evaluateOn(call ground, cell(:n))
        'updateCode)
      result,

      [argName, theCode]
      'initCode
      destructor = Destructor from(argName)
      lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
      self each(n,
        x = lexicalCode call(*(destructor unpack(cell(:n))))
        'updateCode)
      result))),

  Mixins Enumerable map = enumerableMapMethod("takes one or two arguments. if one argument is given, it will be evaluated as a message chain on each element in the enumerable, and then the result will be collected in a new List. if two arguments are given, the first one should be an unevaluated argument name, which will be bound inside the scope of executing the second piece of code. it's important to notice that the one argument form will establish no context, while the two argument form establishes a new lexical closure.",
    result = list(),
    result << cell(:x))

  Mixins Enumerable map:set = enumerableMapMethod("takes one or two arguments. if one argument is given, it will be evaluated as a message chain on each element in the enumerable, and then the result will be collected in a new Set. if two arguments are given, the first one should be an unevaluated argument name, which will be bound inside the scope of executing the second piece of code. it's important to notice that the one argument form will establish no context, while the two argument form establishes a new lexical closure.",
    result = set(),
    result << cell(:x))

  Mixins Enumerable map:dict = enumerableMapMethod("takes one or two arguments. if one argument is given, it will be evaluated as a message chain on each element in the enumerable, and then the result will be collected in a new Dict. if the message chain returns a pair, that pair will be used as key and value. if it's something else, that value will be the key, and the value for it will be nil. if two arguments are given, the first one should be an unevaluated argument name, which will be bound inside the scope of executing the second piece of code. it's important to notice that the one argument form will establish no context, while the two argument form establishes a new lexical closure.",
    result = dict(),
    if(cell(:x) kind == "Pair",
      result[x key] = x value,
      result[cell(:x)] = nil))
)

Mixins Enumerable mapFn = method(
  "takes zero or more arguments that evaluates to lexical blocks. these blocks should all take one argument. these blocks will be chained together and applied on each element in the receiver. the final result will be collected into a list. the evaluation happens left-to-right, meaning the first method invoked will be the first argument.",
  +blocks,

  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()

  self each(n,
    current = cell(:n)
    blocks each(b, current = cell(:b) call(cell(:current)))
    result << current)

  result)

Mixins Enumerable mapFn:dict = method(
  "takes zero or more arguments that evaluates to lexical blocks. these blocks should all take one argument. these blocks will be chained together and applied on each element in the receiver. the final result will be collected into a dict. the evaluation happens left-to-right, meaning the first method invoked will be the first argument.",
  +blocks,

  result = dict()

  self each(n,
    current = cell(:n)
    blocks each(b, current = cell(:b) call(cell(:current)))
    if(cell(:current) mimics?(Pair),
      result[current key] = current value,
      result[cell(:current)] = nil)
  )

  result)

Mixins Enumerable mapFn:set = method(
  "takes zero or more arguments that evaluates to lexical blocks. these blocks should all take one argument. these blocks will be chained together and applied on each element in the receiver. the final result will be collected into a set. the evaluation happens left-to-right, meaning the first method invoked will be the first argument.",
  +blocks,

  result = set()

  self each(n,
    current = cell(:n)
    blocks each(b, current = cell(:b) call(cell(:current)))
    result << current)

  result)

let(enumerableDefaultMethod,
  dsyntax(
    [docstr, initCode, repCode, returnCode]

    ''(dmacro(`docstr,
        []
        'initCode
        self each(n,
          x = cell(:n)
          'repCode)
        'returnCode,

        [theCode]
        'initCode
        self each(n,
          x = theCode evaluateOn(call ground, cell(:n))
          'repCode)
        'returnCode,

        [argName, theCode]
        'initCode
        destructor = Destructor from(argName)
        lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
        self each(n,
          x = lexicalCode call(*(destructor unpack(cell(:n))))
          'repCode)
        'returnCode))),

  Mixins Enumerable any? = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns true if any of the elements yielded by each is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns true. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns true, otherwise false.",
    .,
    if(cell(:x),
      return(true)),
    false)

  Mixins Enumerable none? = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns false if any of the elements yielded by each is true, otherwise true. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns false. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns false, otherwise true.",
    .,
    if(cell(:x),
      return(false)),
    true)

  Mixins Enumerable some = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns the first element that is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, that value is return. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, that value will be returned, otherwise false.",
    .,
    if(cell(:x),
      return(it)),
    false)

  Mixins Enumerable find = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns the first element that is true, otherwise nil. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the corresponding element is returned. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, the element will be retuend, otherwise nil.",
    .,
    if(cell(:x),
      return(cell(:n))),
    nil)

  Mixins Enumerable select = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a list with all the values that are true in the original collection. if one argument is given, it will be applied as a message chain, that should be a predicate. those elements that match the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose elements.",
    result = list(),
    if(cell(:x),
      result << cell(:n)),
    result)

  Mixins Enumerable select:dict = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a dict with all the values that are true in the original collection. if one argument is given, it will be applied as a message chain, that should be a predicate. those elements that match the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose elements.",
    result = dict(),
    if(cell(:x),
      if(cell(:n) mimics?(Pair),
        result[n key] = n value,
        result[cell(:n)] = nil)),
    result)

  Mixins Enumerable select:set = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a set with all the values that are true in the original collection. if one argument is given, it will be applied as a message chain, that should be a predicate. those elements that match the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose elements.",
    result = set(),
    if(cell(:x),
      result << cell(:n)),
    result)

  Mixins Enumerable all? = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns false if any of the elements yielded by each is false, otherwise true. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a false value, the method returns false. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns false for any element, this method returns false, otherwise true.",
    .,
    unless(cell(:x),
      return(false)),
    true)

  Mixins Enumerable one? = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns true if exactly one of the elements is true, otherwise false. if one argument, expects it to be a message chain that will be used as a predicate. if that predicate returns true for exactly one element, returns true, otherwise false. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for exactly one element, returns true, otherwise false",
    result = false,
    if(cell(:x),
      if(result,
        return(false),
        result = true)),
    result)

  Mixins Enumerable count = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns the number of elements in the collection. if one argument, expects it to be a message chain. if that message chain, that will be used as a predicate. returns the number of elements where the predicate returns true. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as a predicate, and the result will be the number of elements matching the predicate.",
    result = 0
    argLength = call arguments length,
    if(cell(:x) || argLength == 0,
      result++),
    result)

  Mixins Enumerable max = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns the maximum elemnt ackording to the <=> ordering. if one argument, expects it to be a message chain. if that message chain, that will be used as a transform to create the element to compare with. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the transformer for comparison. the result will always be an element from the collection, or nil if the collection is empty.",
    theMax = nil
    theMaxVal = nil,

    if(theMax nil?,
      theMax = cell(:n)
      theMaxVal = cell(:x),
      if(theMaxVal < cell(:x),
        theMax = cell(:n)
        theMaxVal = cell(:x))),
    theMax)

  Mixins Enumerable min = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, returns the minimum elemnt ackording to the <=> ordering. if one argument, expects it to be a message chain. if that message chain, that will be used as a transform to create the element to compare with. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the transformer for comparison. the result will always be an element from the collection, or nil if the collection is empty.",
    theMin = nil
    theMinVal = nil,

    if(theMin nil?,
      theMin = cell(:n)
      theMinVal = cell(:x),
      if(theMinVal > cell(:x),
        theMin = cell(:n)
        theMinVal = cell(:x))),
    theMin)

  Mixins Enumerable reject = enumerableDefaultMethod("takes one or two arguments. if one argument is given, it will be applied as a message chain as a predicate. those elements that doesn't the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose the elements that doesn't match.",
    result = list(),
    unless(cell(:x),
      result << cell(:n)),
    result)

  Mixins Enumerable reject:dict = enumerableDefaultMethod("takes one or two arguments. if one argument is given, it will be applied as a message chain as a predicate. those elements that doesn't the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose the elements that doesn't match.",
    result = dict(),
    unless(cell(:x),
      if(cell(:n) mimics?(Pair),
        result[n key] = n value,
        result[cell(:n)] = nil)),
    result)

  Mixins Enumerable reject:set = enumerableDefaultMethod("takes one or two arguments. if one argument is given, it will be applied as a message chain as a predicate. those elements that doesn't the predicate will be returned. if two arguments are given, they will be turned into a lexical block and used as a predicate to choose the elements that doesn't match.",
    result = set(),
    unless(cell(:x),
      result << cell(:n)),
    result)

  Mixins Enumerable partition = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a list containing two list, where the first list contains all true values, and the second all the false values. if one argument is given, it will be used as a predicate message chain, and the return lists will be based on the result of this predicate. finally, if three arguments are given, they will be turned into a lexical block and used as a predicate to determine the result value.",
    resultTrue = list()
    resultFalse = list(),
    if(cell(:x), resultTrue, resultFalse) << cell(:n),
    list(resultTrue, resultFalse))

  Mixins Enumerable partition:set = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a list containing two sets, where the first set contains all true values, and the second all the false values. if one argument is given, it will be used as a predicate message chain, and the return sets will be based on the result of this predicate. finally, if three arguments are given, they will be turned into a lexical block and used as a predicate to determine the result value.",
    resultTrue = set()
    resultFalse = set(),
    if(cell(:x), resultTrue, resultFalse) << cell(:n),
    list(resultTrue, resultFalse))

  Mixins Enumerable partition:dict = enumerableDefaultMethod("takes zero, one or two arguments. if zero arguments, will return a list containing two dicts, where the first dict contains all true values, and the second all the false values. if one argument is given, it will be used as a predicate message chain, and the return dicts will be based on the result of this predicate. finally, if three arguments are given, they will be turned into a lexical block and used as a predicate to determine the result value.",
    resultTrue = dict()
    resultFalse = dict(),

    place = if(cell(:x), resultTrue, resultFalse)
    if(cell(:n) mimics?(Pair),
      place[n key] = n value,
      place[cell(:n)] = nil),

    list(resultTrue, resultFalse))

  Mixins Enumerable takeWhile = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and collect all the elements until the predicate returns false for the first time. at that point the collected list will be returned. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",
    result = list(),
    if(cell(:x),
      result << cell(:n),
      return(result)),
    result)

  Mixins Enumerable takeWhile:set = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and collect all the elements until the predicate returns false for the first time. at that point the collected set will be returned. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",
    result = set(),
    if(cell(:x),
      result << cell(:n),
      return(result)),
    result)

  Mixins Enumerable takeWhile:dict = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and collect all the elements until the predicate returns false for the first time. at that point the collected dict will be returned. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",
    result = dict(),
    if(cell(:x),
      if(cell(:n) mimics?(Pair),
        result[n key] = n value,
        result[cell(:n)] = nil),
      return(result)),
    result)

  Mixins Enumerable dropWhile = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and avoid all the elements until the predicate returns false for the first time, then it will start collecting data. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",

    result = list()
    collecting = false,
    if(collecting,
      result << cell(:n),
      unless(cell(:x),
        collecting = true
        result << cell(:n))),
    result)

  Mixins Enumerable dropWhile:dict = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and avoid all the elements until the predicate returns false for the first time, then it will start collecting data. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",

    result = dict()
    collecting = false,
    if(collecting,
      if(cell(:n) mimics?(Pair),
        result[n key] = n value,
        result[cell(:n)] = nil),
      unless(cell(:x),
        collecting = true
        if(cell(:n) mimics?(Pair),
          result[n key] = n value,
          result[cell(:n)] = nil))),
    result)

  Mixins Enumerable dropWhile:set = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate a predicate once for each element, and avoid all the elements until the predicate returns false for the first time, then it will start collecting data. if zero arguments, the predicate is the element itself. if one argument, expects it to be a message chain to apply as a predicate. if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and used as the predicate.",

    result = set()
    collecting = false,
    if(collecting,
      result << cell(:n),
      unless(cell(:x),
        collecting = true
        result << cell(:n))),
    result)

  Mixins Enumerable groupBy = enumerableDefaultMethod("takes zero, one or two arguments. it will evaluate all the elements in the enumerable and return a dictionary where the keys will be the result of evaluating the arguments and the value will be a list of all the original values that match that key.",
    result = dict(),
    if(result key?(cell(:x)),
      result[cell(:x)] << cell(:n),
      result[cell(:x)] = list(cell(:n))),
    result)
)

Mixins Enumerable findIndex = dmacro("takes zero, one or two arguments. if zero arguments, returns the index of the first element that is true, otherwise nil. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the corresponding element index is returned. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, the element index will be returned, otherwise nil.",

  []
  self each(ix, n, if(cell(:n), return(ix)))
  nil,

  [theCode]
  self each(ix, n, if(theCode evaluateOn(call ground, cell(:n)), return(ix)))
  nil,

  [argName, theCode]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
  self each(ix, n, if(lexicalCode call(*(destructor unpack(cell(:n)))), return(ix)))
  nil)

Mixins Enumerable sortBy = dmacro(
  "takes one or two arguments that are used to transform the objects into something that can be sorted, then sorts based on that. if one argument, that argument is handled as a message chain, and if two arguments it will be turned into a lexical block and used.",

  [theCode]
  map(x, list(theCode evaluateOn(call ground, cell(:x)), cell(:x))) sort map(second),

  [argName, theCode]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
  map(x, list(lexicalCode call(*(destructor unpack(cell(:x)))), cell(:x))) sort map(second))

Mixins Enumerable inject = dmacro(
  "takes one, two, three or four arguments. all versions need an initial sum, code to execute, a place to put the current sum in the code, and a place to stick the current element of the enumerable. if one argument, it has to be a message chain. this message chain will be applied on the current sum. the element will be appended to the argument list of the last message send in the chain. the initial sum is the first element, and the code will be executed once less than the size of the enumerable due to this. if two arguments given, the first argument is the name of the variable to put the current element in, and the message will still be sent to the sum - and the initial sum works the same way as for one argument. when three arguments are given, the whole thing will be turned into a lexical closure, where the first argument is the name of the sum variable, the second argument is the name of the element variable, and the last argument is the code. when given four arguments, the only difference is that the first argument will be evaluated as the initial sum.",

  [theCode]
  theCode = theCode deepCopy
  elementName = genSym
  theCode last << message(elementName)

  sum = nil

  self each(i, n,
    if(i == 0,
      sum = cell(:n),

      call ground cell(elementName) = cell(:n)
      sum = theCode evaluateOn(call ground, cell(:sum))))
  return(cell(:sum)),


  [argName, theCode]
  elementName = argName name
  sum = nil

  self each(i, n,
    if(i == 0,
      sum = cell(:n),

      call ground cell(elementName) = cell(:n)
      sum = theCode evaluateOn(call ground, cell(:sum))))

  return(cell(:sum)),


  [sumArgName, argName, theCode]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(list(sumArgName) + destructor argNames + list(theCode), call ground)
  sum = nil
  self each(i, n,
    if(i == 0,
      sum = cell(:n),
      sum = lexicalCode call(cell(:sum), *(destructor unpack(cell(:n))))))

  return(cell(:sum)),


  [>sum, sumArgName, argName, theCode]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(list(sumArgName) + destructor argNames + list(theCode), call ground)
  self each(n,
    sum = lexicalCode call(cell(:sum), *(destructor unpack(cell(:n)))))
  return(cell(:sum)))

Mixins Enumerable flatMap = macro(
  "expects to get the same kind of arguments as map, and that each map operation returns a list. these lists will then be folded into a single list.",

  call resendToMethod("map") fold(+))

Mixins Enumerable flatMap:set = macro(
  "expects to get the same kind of arguments as map:set, and that each map operation returns a set. these sets will then be folded into a single set.",

  call resendToMethod("map:set") fold(+))

Mixins Enumerable flatMap:dict = macro(
  "expects to get the same kind of arguments as map:dict, and that each map operation returns a dict for key. these dicts will then be folded into a single dict.",

  call resendToMethod("map:dict") fold({}, sum, arg,
    arg key each(val,
      sum[val key] = val value)
    sum)
)

Mixins Enumerable first = method(
  "takes one optional argument. if no argument is given, first will return the first element in the collection, or nil if no such element exists. if an argument is given, it should be a number describing how many elements to get. the return value will be a list in that case",
  howMany nil,

  if(howMany,
    result = list()
    self each(n,
      if(howMany == 0, return(result))
      howMany--
      result << cell(:n))
    return(result),

    self each(n, return(cell(:n)))
    return(nil)))

Mixins Enumerable first:dict = method(
  "takes one argument. the argument should be a number describing how many elements to get. the return value will be a dict",
  howMany,

  result = dict()
  self each(n,
    if(howMany == 0, return(result))
    howMany--
    if(cell(:n) mimics?(Pair),
      result[n key] = n value,
      result[cell(:n)] = nil))
  return(result))

Mixins Enumerable first:set = method(
  "takes one argument. the argument should be a number describing how many elements to get. the return value will be a set",
  howMany,

  result = set()
  self each(n,
    if(howMany == 0, return(result))
    howMany--
    result << cell(:n))
  return(result))

Mixins Enumerable include? = method(
  "takes one argument and returns true if this element is in the collection. comparisons is done with ==.",
  toFind,

  self each(n,
    if(toFind == cell(:n),
      return(true)))
  return(false))

Mixins Enumerable take = method(
  "takes one argument and returns a list with as many elements from the collection, or all elements if the requested number is larger than the size.",
  howMany,

  self first(howMany))

Mixins Enumerable take:dict = method(
  "takes one argument and returns a dict with as many elements from the collection, or all elements if the requested number is larger than the size.",
  howMany,

  self first:dict(howMany))

Mixins Enumerable take:set = method(
  "takes one argument and returns a set with as many elements from the collection, or all elements if the requested number is larger than the size.",
  howMany,

  self first:set(howMany))

Mixins Enumerable drop = method(
  "takes one argument and returns a list of all the elements in this object except for how many that should be avoided.",
  howMany,

  result = list()
  currentCount = howMany
  self each(n,
    if(currentCount > 0,
      currentCount--,
      result << cell(:n)))
  result)

Mixins Enumerable drop:dict = method(
  "takes one argument and returns a dict of all the elements in this object except for how many that should be avoided.",
  howMany,

  result = dict()
  currentCount = howMany
  self each(n,
    if(currentCount > 0,
      currentCount--,
      if(cell(:n) mimics?(Pair),
        result[n key] = n value,
        result[cell(:n)] = nil)))
  result)

Mixins Enumerable drop:set = method(
  "takes one argument and returns a set of all the elements in this object except for how many that should be avoided.",
  howMany,

  result = set()
  currentCount = howMany
  self each(n,
    if(currentCount > 0,
      currentCount--,
      result << cell(:n)))
  result)

Mixins Enumerable cycle = dmacro(
  "takes one or two arguments and cycles over the elements of this collection. the cycling will be done by calling each once and collecting the result, and then using this to continue cycling. if one argument is given, it should be a message chain to apply. if two arguments are given, they will be turned into a lexical block and applied. if the collection is empty, returns nil.",

  [theCode]
  internal = list()
  self each(n,
    internal << cell(:n)
    theCode evaluateOn(call ground, cell(:n)))
  if(internal empty?, return(nil))
  loop(internal each(x, theCode evaluateOn(call ground, cell(:x)))),

  [argName, theCode]
  internal = list()
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
  self each(n,
    internal << cell(:n)
    lexicalCode call(*(destructor unpack(cell(:n)))))
  if(internal empty?, return(nil))
  loop(internal each(x, lexicalCode call(*(destructor unpack(cell(:x)))))))

Mixins Enumerable zip = method(
  "takes zero or more arguments, where all arguments should be a list, except that the last might also be a lexical block. zip will create a list of lists, where each internal list is a combination of the current element, and the corresponding elements from all the lists. if the lists are shorter than this collection, nils will be supplied. if a lexical block is provided, it will be called with each list created, and if that's the case nil will be returned from zip",
  +listsAndFns,

  theFn = listsAndFns last
  if(cell(:theFn) && (cell(:theFn) mimics?(LexicalBlock)),
    listsAndFns = listsAndFns[0..0-2]
    listsAndFns map!(x,
      if(x mimics?(Sequence),
        x,
        x seq))
    self each(n,
      internal = list(cell(:n))
      listsAndFns each(n2,
        val = if(n2 next?, n2 next, nil)
        internal << cell(:val))
      cell(:theFn) call(internal))
    nil,

    listsAndFns map!(x,
      if(x mimics?(Sequence),
        x,
        x seq))
    result = list()
    self each(n,
      internal = list(cell(:n))
      listsAndFns each(n2,
        val = if(n2 next?, n2 next, nil)
        internal << cell(:val))
      result << internal)
    result))

Mixins Enumerable zip:set = method(
  "takes zero or more arguments, where all arguments should be lists or sequences. zip:set will create a list of set, where each internal set is a combination of the current element, and the corresponding elements from all the lists. if the lists are shorter than this collection, nils will be supplied.",
  +lists,

  lists map!(x,
    if(x mimics?(Sequence),
      x,
      x seq))
  result = list()
  self each(n,
    internal = set(cell(:n))
    lists each(n2,
      val = if(n2 next?, n2 next, nil)
      internal << cell(:val))
    result << internal)
  result)

Mixins Enumerable grep = dmacro(
  "takes one, two or three arguments. grep will first find any elements in the collection matching the first argument with '==='. if two or three arguments are given, these will be used to transform the matching object and then add the transformed version instead of the original element to the result list. the two argument version expects the second argument to be a message chain, and the three argument version expects it to be something that can be turned into a lexical block",

  [>matchingAgainst]
  result = list()
  self each(n,
    if(matchingAgainst === cell(:n),
      result << cell(:n)))
  result,

  [>matchingAgainst, theCode]
  result = list()
  self each(n,
    if(matchingAgainst === cell(:n),
      result << theCode evaluateOn(call ground, cell(:n))))
  result,

  [>matchingAgainst, argName, theCode]
  destructor = Destructor from(argName)
  result = list()
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
  self each(n,
    if(matchingAgainst === cell(:n),
      result << lexicalCode call(*(destructor unpack(cell(:n))))))
  result)


Mixins Enumerable grep:set = dmacro(
  "takes one, two or three arguments. grep will first find any elements in the collection matching the first argument with '==='. if two or three arguments are given, these will be used to transform the matching object and then add the transformed version instead of the original element to the result set. the two argument version expects the second argument to be a message chain, and the three argument version expects it to be something that can be turned into a lexical block",

  [>matchingAgainst]
  result = set()
  self each(n,
    if(matchingAgainst === cell(:n),
      result << cell(:n)))
  result,

  [>matchingAgainst, theCode]
  result = set()
  self each(n,
    if(matchingAgainst === cell(:n),
      result << theCode evaluateOn(call ground, cell(:n))))
  result,

  [>matchingAgainst, argName, theCode]
  destructor = Destructor from(argName)
  result = set()
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(theCode), call ground)
  self each(n,
    if(matchingAgainst === cell(:n),
      result << lexicalCode call(*(destructor unpack(cell(:n))))))
  result)


Mixins Enumerable join = method(
  "returns a string created by converting each element of the array to text, separated by an optional separator",
  separator "",

  result = ""
  self each(index, n,
    result += (n asText)
    if(index < count - 1, result += separator))
  result)

Mixins Enumerable sum = method(
  "returns an object created by summing all objects in the enumerable using the + operator. the default value for an empty enumerable will be nil.",
  inject(+))

Mixins Enumerable group = method(
  "returns a dict where all the keys are distinct elements in the enumerable, and each value is a list of all the values that are equivalent",
  groupBy)

Mixins Enumerable Destructor = Origin mimic do(
  Mapper = Origin mimic
  Mapper RegularArgument = Mapper mimic do(
    assign = method(values, val, values << val. values)
  )
  Mapper Ignore = Mapper with(last?: false, arguments: [])
  Mapper Recursive = Mapper mimic do(
    arguments = method(mappers flatMap(arguments))
    assign = method(values, val,
      Mixins Enumerable Destructor mapValue(val, mappers, values)
      values
    )

    from = method(arg,
      mimic tap(mappers = Mixins Enumerable Destructor createMappersFrom(arg arguments))
    )
  )

  Mapper assign = method(values, ignore, values)
  Mapper from = method(arg,
    case(arg name,
      :"_", Ignore mimic,
      :"", Recursive from(arg),
      else, RegularArgument with(arg: arg, arguments: [arg])))

  createMappersFrom = method(arguments,
    arguments map(x, Mapper from(x)) tap(m, 
      if(m[-1] mimics?(Mapper Ignore),
        m[-1] last? = true)))

  argumentNamesFromMappers = method(mappers flatMap(arguments))

  nested? = false

  from = method(arg,
    newD = mimic

    if(arg name == :"",
      newD mappers = createMappersFrom(arg arguments)
      newD argNames = newD argumentNamesFromMappers
      newD nested? = true,
      newD argNames = [arg]
    )

    newD
  )

  mapValue = method(value, ms, result [],
    value = value asTuple asList
    if((ms length < value length && !(ms[-1] mimics?(Mapper Ignore))) || 
      value length < ms length,
      error!(Condition Error DestructuringMismatch)
    )

    ms zip(value) fold(result, values, mapperAndValue,
      mapperAndValue first assign(values, mapperAndValue second))
  )

  unpack = method(value,
    if(nested?,
      mapValue(cell(:value), mappers),
      list(cell(:value)))
  )
)


Mixins Enumerable eachCons = dmacro(
  "takes one, two or three arguments. if one argument, assumes this to be a message chain and the cons length to be two. if two arguments, expects the first to be the cons length and the second to be the message chain. if three, expects the first to be the cons length, the second to be a variable name and the third to be a message chain. will yield lists of length consLength counting from the beginning of the enumerable",
  [code]
  consLength = 2
  ary = list()
  
  self each(n,
    if(ary length == consLength,
      ary shift!)
    ary push!(n)
    if(ary length == consLength,
      code evaluateOn(call ground, ary mimic))
  )  
  self
  ,
  [>consLength, code]
  ary = list()
  
  self each(n,
    if(ary length == consLength,
      ary shift!)
    ary push!(n)
    if(ary length == consLength,
      code evaluateOn(call ground, ary mimic))
  )  
  self
  ,
  [>consLength, argName, code]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(code), call ground)
  ary = list()
  
  self each(n,
    if(ary length == consLength,
      ary shift!)
    ary push!(n)
    if(ary length == consLength,
      lexicalCode call(*(destructor unpack(ary mimic))))
  )
  self
)

Mixins Enumerable eachSlice = dmacro(
  "takes one, two or three arguments. if one argument, assumes this to be a message chain and the slice length to be two. if two arguments, expects the first to be the slice length and the second to be the message chain. if three, expects the first to be the slice length, the second to be a variable name and the third to be a message chain. will yield lists of length sliceLength counting from the beginning of the enumerable",
  [code]
  sliceLength = 2
  ary = list()
  
  self each(n,
    ary push!(n)
    if(ary length == sliceLength,
      code evaluateOn(call ground, ary)
      ary = list())
  )
  if(ary length > 0, code evaluateOn(call ground, ary))
  self
  ,
  [>sliceLength, code]
  ary = list()
  
  self each(n,
    ary push!(n)
    if(ary length == sliceLength,
      code evaluateOn(call ground, ary)
      ary = list())
  )
  if(ary length > 0, code evaluateOn(call ground, ary))
  self
  ,
  [>sliceLength, argName, code]
  destructor = Destructor from(argName)
  lexicalCode = LexicalBlock createFrom(destructor argNames + list(code), call ground)
  ary = list()
  
  self each(n,
    ary push!(n)
    if(ary length == sliceLength,
      lexicalCode call(*(destructor unpack(ary)))
      ary = list())
  )
  if(ary length > 0, lexicalCode call(*(destructor unpack(ary))))
  self
)

Mixins Enumerable aliasMethod("map", "collect")
Mixins Enumerable aliasMethod("map", "collect:list")
Mixins Enumerable aliasMethod("map", "map:list")
Mixins Enumerable aliasMethod("map:set", "collect:set")
Mixins Enumerable aliasMethod("map:dict", "collect:dict")
Mixins Enumerable aliasMethod("flatMap", "flatMap:list")
Mixins Enumerable aliasMethod("mapFn", "collectFn")
Mixins Enumerable aliasMethod("mapFn:set", "collectFn:set")
Mixins Enumerable aliasMethod("mapFn:dict", "collectFn:dict")
Mixins Enumerable aliasMethod("find", "detect")
Mixins Enumerable aliasMethod("inject", "reduce")
Mixins Enumerable aliasMethod("inject", "fold")
Mixins Enumerable aliasMethod("select", "findAll")
Mixins Enumerable aliasMethod("select", "filter")
Mixins Enumerable aliasMethod("select:dict", "findAll:dict")
Mixins Enumerable aliasMethod("select:dict", "filter:dict")
Mixins Enumerable aliasMethod("select:set", "findAll:set")
Mixins Enumerable aliasMethod("select:set", "filter:set")
Mixins Enumerable aliasMethod("include?", "member?")


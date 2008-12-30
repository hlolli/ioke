
DefaultBehavior .. = method(
  "will create and return an inclusive Range from the receiver to the 'to' argument.",
  to,
  Range inclusive(cell(:"@"), cell(:to)))

DefaultBehavior ... = method(
  "will create and return an exclusive Range from the receiver to the 'to' argument.",
  to,
  Range exclusive(cell(:"@"), cell(:to)))

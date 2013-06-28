
When a node starts running, it is either a Split or not a Split node.

If it is a split node, it needs to

1. Decide the number of duplicates of its child node
2. Instantiate duplicates of the child nodes and establish connections with them
3. Execute
4. Emit to the proper outputs

Otherwise, it simply needs to execute, and route outputs to the right handlers.

### Connections:

::Inputs::

Each node takes as input a single table (except JOIN and Barrier).  They expose a setInput
method that sets the input slot.

  node.setInput

Join and Barrier must track how many inputs they need to run.
The number of inputs is defined by the number of times they are duplicated

When clone() is called, a normal Node should:

1. Make a copy of itself (same spec/initial configuration. Doesn't include child nodes)
2. Return the copy and the copy's setInput handler

When clone() is called, Join should:

1. Check if it's a stopping point.  If yes
      1. Allocate a new input slot
      2. Return itself, and the input slot's handler
   Otherwise
      1. Copy itself
      2. Return copy, and the copy's single input slot handler

When clone() is called, Barrier should:

1. Allocate a new input slot
2. Get a copy of it's child
3. Hook the child's input handler to the i'th output
4. Return self, and the new input slot's handler


CloneSubplan() is identical to Clone(), but also

1. clones the children
2. hooks up the clone's output handlers to the children's input handlers
3. Returns clone and clone's input handler



In the future we may have Virtual Nodes, one for each multi-input node so that every
node has a single setInput method.


::Outputs::

Each node (except Split/Barrier/Multicast) outputs a single table, passed as (id, table).
The results are passed through an event handler:

  node.emit "output", id, table

Multi-output nodes (Split, Barrirer, Multicast) need to let children register
for particular outputs.  The idx'th output is passed through:

  node.emit "#{idx}", id, table

It's externally confusing which "output-idx" to bind to.  Thus, the convention is
for the i'th child in the node.children array to bind to "output-i".  This binding should be
handled within the addChild method.





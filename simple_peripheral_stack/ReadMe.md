simple_peripheral_stack build outputs:
├── simple_peripheral_stack.out   ← flashable stack image
├── simple_peripheral_stack.hex   ← hex for flashing
├── simple_peripheral_stack.map   ← memory map
├── simple_peripheral_stack.xml   ← consumed by frontier.py
└── boundary/
    ├── compiler_boundary.opt     ← consumed by app compiler
    └── linker_boundary.cmd       ← consumed by app linker
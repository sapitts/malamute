## first attempt to set up mesh, units in meters

powder_radius = 0.006
powder_height = 0.00984

#### remainder of these parameters should stay the same among runs

steel_ram_radius = 0.026 ##assumed based on the recess diameter in the ram spacer
steel_ram_height = 0.00635 ## to the thermocouple location in the rams


ram_spacer_steel_overhang_radius = 0.0045
ram_spacer_radius = 0.031
ram_spacer_height = 0.020
ram_spacer_overhang_radius = 0.01
ram_spacer_overhang_height = 0.002

cc_spacer_radius = 0.020
cc_spacer_height = 0.00635

sinter_spacer_radius = 0.020
sinter_spacer_height = 0.027
sinter_spacer_overhang_radius = 0.0135 ## is less than the 13.55 that actually exists
sinter_spacer_overhang_height = 0.002

punch_radius = 0.006
punch_height = 0.020

die_wall_inner_radius = 0.006125
die_wall_outer_radius = 0.020
die_wall_height = 0.030




### Calculated values from user-provided results
ram_steel_spacer_height = ${fparse steel_ram_height + ram_spacer_height}
ram_cc_spacers_height = ${fparse ram_steel_spacer_height + cc_spacer_height}
ram_cc_sinter_spacers_height = ${fparse ram_cc_spacers_height + sinter_spacer_height}
ram_cc_sinter_punch_height = ${fparse ram_cc_sinter_spacers_height + punch_height}
stack_with_powder = ${fparse ram_cc_sinter_punch_height + powder_height}



[Mesh]
  [bottom_steel_ram]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${steel_ram_radius}
    ymax = ${steel_ram_height}
    boundary_name_prefix = bottom_steel_ram
    elem_type = QUAD8
  []
  [bottom_steel_ram_block]
    type = SubdomainIDGenerator
    input = 'bottom_steel_ram'
    subdomain_id = '1'
  []

  [bottom_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 62
    ny = 20
    xmax = ${ram_spacer_radius}
    ymin = ${steel_ram_height}
    ymax = ${ram_steel_spacer_height}
    boundary_name_prefix = bottom_ram_spacer
    elem_type = QUAD8
    boundary_id_offset = 8
  []
  [bottom_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${ram_steel_spacer_height}
    ymax = ${fparse ram_steel_spacer_height + ram_spacer_overhang_height}
    boundary_name_prefix = bottom_ram_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 12
  []
  [bottom_ram_spacer_recess]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 9
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_steel_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${fparse steel_ram_height - ram_spacer_overhang_height}
    ymax = ${steel_ram_height}
    boundary_name_prefix = bottom_ram_spacer_recess
    elem_type = QUAD8
    boundary_id_offset = 16
  []
  [stitch_bottom_ram_recess]
    type = StitchedMeshGenerator
    inputs = 'bottom_ram_spacer bottom_ram_spacer_recess'
    stitch_boundaries_pairs = 'bottom_ram_spacer_bottom bottom_ram_spacer_recess_top'
  []
  [stitch_bottom_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'stitch_bottom_ram_recess bottom_ram_overhang'
    stitch_boundaries_pairs = 'bottom_ram_spacer_top bottom_ram_spacer_overhang_bottom'
  []
  [bottom_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_ram_spacer'
    subdomain_id = '2'
  []
  [bottom_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${ram_steel_spacer_height}
    ymax = ${ram_cc_spacers_height}
    boundary_name_prefix = 'bottom_cc_spacer'
    boundary_id_offset = 20
    elem_type = QUAD8
  []
  [bottom_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'bottom_cc_spacer'
    subdomain_id = '3'
  []
  [bottom_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${sinter_spacer_radius}
    ymin = ${ram_cc_spacers_height}
    ymax = ${ram_cc_sinter_spacers_height}
    boundary_name_prefix = bottom_sinter_spacer
    boundary_id_offset = 24
    elem_type = QUAD8
  []
  [bottom_sinter_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 27
    ny = 2
    xmin = ${fparse sinter_spacer_radius - sinter_spacer_overhang_radius}
    xmax = ${sinter_spacer_radius}
    ymin = ${ram_cc_sinter_spacers_height}
    ymax = ${fparse ram_cc_sinter_spacers_height + sinter_spacer_overhang_height}
    boundary_name_prefix = bottom_sinter_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 28
  []
  [stitch_bottom_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'bottom_sinter_spacer bottom_sinter_overhang'
    stitch_boundaries_pairs = 'bottom_sinter_spacer_top bottom_sinter_spacer_overhang_bottom'
  []
  [bottom_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_sinter_spacer'
    subdomain_id = '4'
  []
 [bottom_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${ram_cc_sinter_spacers_height}
    ymax = ${ram_cc_sinter_punch_height}
    boundary_name_prefix = 'bottom_punch'
    elem_type = QUAD8
    boundary_id_offset = 32
  []
  [bottom_punch_block]
    type = SubdomainIDGenerator
    input = bottom_punch
    subdomain_id = 5
  []

  [powder]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 15
    ny = 18
    xmax = ${powder_radius}
    ymin = ${ram_cc_sinter_punch_height}
    ymax = ${stack_with_powder}
    boundary_name_prefix = powder
    elem_type = QUAD8
    boundary_id_offset = 36
  []
  [powder_block]
    type = SubdomainIDGenerator
    input = powder
    subdomain_id = 6
  []

  [top_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${stack_with_powder}
    ymax = ${fparse stack_with_powder + punch_height}
    boundary_name_prefix = 'top_punch'
    elem_type = QUAD8
    boundary_id_offset = 40
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = top_punch
    subdomain_id = 7
  []
  [top_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${sinter_spacer_radius}
    ymin = ${fparse stack_with_powder + punch_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_cc_spacers_height}
    boundary_name_prefix = top_sinter_spacer
    boundary_id_offset = 44
    elem_type = QUAD8
  []
  [top_sinter_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 27
    ny = 2
    xmin = ${fparse sinter_spacer_radius - sinter_spacer_overhang_radius}
    xmax = ${sinter_spacer_radius}
    ymin = ${fparse stack_with_powder + punch_height - sinter_spacer_overhang_height}
    ymax = ${fparse stack_with_powder + punch_height}
    boundary_name_prefix = top_sinter_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 48
  []
  [stitch_top_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'top_sinter_spacer top_sinter_overhang'
    stitch_boundaries_pairs = 'top_sinter_spacer_bottom top_sinter_spacer_overhang_top'
  []
  [top_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_sinter_spacer'
    subdomain_id = '8'
  []
  [top_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_cc_spacers_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_steel_spacer_height}
    boundary_name_prefix = 'top_cc_spacer'
    boundary_id_offset = 52
    elem_type = QUAD8
  []
  [top_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'top_cc_spacer'
    subdomain_id = '9'
  []
  [top_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 62
    ny = 20
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_steel_spacer_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - steel_ram_height}
    boundary_name_prefix = top_ram_spacer
    elem_type = QUAD8
    boundary_id_offset = 56
  []
  [top_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_steel_spacer_height - ram_spacer_overhang_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_steel_spacer_height}
    boundary_name_prefix = top_ram_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 60
  []
  [top_ram_spacer_recess]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 9
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_steel_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - steel_ram_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - steel_ram_height + ram_spacer_overhang_height}
    boundary_name_prefix = top_ram_spacer_recess
    elem_type = QUAD8
    boundary_id_offset = 64
  []
  [stitch_top_ram_recess]
    type = StitchedMeshGenerator
    inputs = 'top_ram_spacer top_ram_spacer_recess'
    stitch_boundaries_pairs = 'top_ram_spacer_top top_ram_spacer_recess_bottom'
  []
  [stitch_top_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'stitch_top_ram_recess top_ram_overhang'
    stitch_boundaries_pairs = 'top_ram_spacer_bottom top_ram_spacer_overhang_top'
  []
  [top_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_ram_spacer'
    subdomain_id = '10'
  []

  [top_steel_ram]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${steel_ram_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - steel_ram_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height}
    boundary_name_prefix = top_steel_ram
    elem_type = QUAD8
    boundary_id_offset = 72
  []
  [top_steel_ram_block]
    type = SubdomainIDGenerator
    input = 'top_steel_ram'
    subdomain_id = '11'
  []

  [die_wall]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 14
    ny = 30
    xmin = ${die_wall_inner_radius}
    xmax = ${die_wall_outer_radius}
    ymin = ${fparse ram_cc_sinter_punch_height + (powder_height - die_wall_height) / 2.0}
    ymax = ${fparse ram_cc_sinter_punch_height + (powder_height + die_wall_height) / 2.0}
    boundary_name_prefix = die_wall
    elem_type = QUAD8
    boundary_id_offset = 76
  []
  [die_wall_block]
    type = SubdomainIDGenerator
    input = 'die_wall'
    subdomain_id = 12
  []

  [fourteen_blocks]
    type = MeshCollectionGenerator
    inputs = 'bottom_steel_ram_block bottom_ram_spacer_block bottom_cc_spacer_block
              bottom_sinter_spacer_block bottom_punch_block powder_block
              top_punch_block top_sinter_spacer_block top_cc_spacer_block
              top_ram_spacer_block top_steel_ram_block die_wall_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = fourteen_blocks
    old_block = '1 2 3 4 5 6 7 8 9 10 11 12'
    new_block = 'bottom_steel_ram bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer
                 bottom_punch powder top_punch top_sinter_spacer top_cc_spacer
                  top_ram_spacer top_steel_ram die_wall'
  []
  patch_update_strategy = iteration
  second_order = true
  coord_type = RZ
[]

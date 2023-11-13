## first attempt to set up mesh, units in meters

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

powder_radius = 0.006
powder_height = 0.00984

die_wall_inner_radius = 0.006125
die_wall_outer_radius = 0.020
die_wall_height = 0.030


#######################################################################################
### Calculated values from user-provided results
# ram_spacer_overhang_offset = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
ram_cc_spacers_height = ${fparse ram_spacer_height + cc_spacer_height}
ram_cc_sinter_spacers_height = ${fparse ram_cc_spacers_height + sinter_spacer_height}
ram_cc_sinter_punch_height = ${fparse ram_cc_sinter_spacers_height + punch_height}
stack_with_powder = ${fparse ram_cc_sinter_punch_height + powder_height}



[Mesh]
  [bottom_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${ram_spacer_radius}
    ymax = ${ram_spacer_height}
    boundary_name_prefix = bottom_ram_spacer
    elem_type = QUAD8
  []
  [bottom_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${ram_spacer_height}
    ymax = ${fparse ram_spacer_height + ram_spacer_overhang_height}
    boundary_name_prefix = bottom_ram_spacer_overhang
    elem_type = QUAD8
  []
  [stitch_bottom_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'bottom_ram_spacer bottom_ram_overhang'
    stitch_boundaries_pairs = 'bottom_ram_spacer_top bottom_ram_spacer_overhang_bottom'
  []
  [bottom_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_ram_spacer'
    subdomain_id = '1'
  []
  [bottom_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${ram_spacer_height}
    ymax = ${ram_cc_spacers_height}
    boundary_name_prefix = 'bottom_cc_spacer'
    boundary_id_offset = 8
    elem_type = QUAD8
  []
  [bottom_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'bottom_cc_spacer'
    subdomain_id = '2'
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
    boundary_id_offset = 12
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
    boundary_id_offset = 16
  []
  [stitch_bottom_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'bottom_sinter_spacer bottom_sinter_overhang'
    stitch_boundaries_pairs = 'bottom_sinter_spacer_top bottom_sinter_spacer_overhang_bottom'
  []
  [bottom_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_sinter_spacer'
    subdomain_id = '3'
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
    boundary_id_offset = 20
  []
  [bottom_punch_block]
    type = SubdomainIDGenerator
    input = bottom_punch
    subdomain_id = 4
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
    boundary_id_offset = 24
  []
  [powder_block]
    type = SubdomainIDGenerator
    input = powder
    subdomain_id = 5
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
    boundary_id_offset = 28
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = top_punch
    subdomain_id = 6
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
    boundary_id_offset = 32
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
    boundary_id_offset = 36
  []
  [stitch_top_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'top_sinter_spacer top_sinter_overhang'
    stitch_boundaries_pairs = 'top_sinter_spacer_bottom top_sinter_spacer_overhang_top'
  []
  [top_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_sinter_spacer'
    subdomain_id = '7'
  []
  [top_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_cc_spacers_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    boundary_name_prefix = 'top_cc_spacer'
    boundary_id_offset = 40
    elem_type = QUAD8
  []
  [top_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'top_cc_spacer'
    subdomain_id = '8'
  []
  [top_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height}
    boundary_name_prefix = top_ram_spacer
    elem_type = QUAD8
    boundary_id_offset = 44
  []
  [top_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height - ram_spacer_overhang_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    boundary_name_prefix = top_ram_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 48
  []
  [stitch_top_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'top_ram_spacer top_ram_overhang'
    stitch_boundaries_pairs = 'top_ram_spacer_bottom top_ram_spacer_overhang_top'
  []
  [top_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_ram_spacer'
    subdomain_id = '9'
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
    boundary_id_offset = 52
  []
  [die_wall_block]
    type = SubdomainIDGenerator
    input = 'die_wall'
    subdomain_id = 10
  []

  [ten_blocks]
    type = MeshCollectionGenerator
    inputs = 'bottom_ram_spacer_block bottom_cc_spacer_block bottom_sinter_spacer_block
              bottom_punch_block powder_block top_punch_block top_sinter_spacer_block
              top_cc_spacer_block top_ram_spacer_block die_wall_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = ten_blocks
    old_block = '1 2 3 5 6 7 8 9 10'
    new_block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
                 powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
  patch_update_strategy = iteration
  second_order = true
  coord_type = RZ
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  converge_on = 'temperature potential'
[]

[Variables]
  [temperature]
    initial_condition = 300.0
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
    order = SECOND
  []
  [potential]
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
    order = SECOND
  []
[]

[AuxVariables]
  [heat_transfer_radiation]
    order = SECOND
  []

  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = potential
    diffusivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = graphite_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []

  [HeatDiff_carbon_fiber]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = carbon_fiber_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [HeatTdot_carbon_fiber]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = carbon_fiber_heat_capacity
    density_name = carbon_fiber_density
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [electric_carbon_fiber]
    type = ADMatDiffusion
    variable = potential
    diffusivity = carbon_fiber_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [JouleHeating_carbon_fiber]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = carbon_fiber_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []

  [HeatDiff_powder]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = iron_powder_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [HeatTdot_powder]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = iron_powder_heat_capacity
    density_name = iron_powder_density
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [electric_powder]
    type = ADMatDiffusion
    variable = potential
    diffusivity = iron_powder_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [JouleHeating_powder]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = iron_powder_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'bottom_ram_spacer_right bottom_ram_spacer_overhang_right bottom_cc_spacer_right
                bottom_sinter_spacer_right bottom_sinter_spacer_overhang_right bottom_punch_right
                top_punch_right top_sinter_spacer_overhang_right top_sinter_spacer_right
                top_cc_spacer_right top_ram_spacer_overhang_right top_ram_spacer_right die_wall_right'
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield' #published emissivity for graphite is 0.85
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []

  [electrostatic_calculation_x]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_x
    sign = negative
    component = x
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
[]

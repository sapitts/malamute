## Units in the input file: m-Pa-s-K-V

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
[]

[Mesh]
  [top_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 20
    xmax = 0.031
    ymin = 0.05354
    ymax = 0.07754
    boundary_name_prefix = top_ram_spacer
    elem_type = QUAD8
  []
  [top_ram_spacer_block]
    type = SubdomainIDGenerator
    input = top_ram_spacer
    subdomain_id = 1
  []
  [top_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmax = 0.02
    ymin = 0.03254
    ymax = 0.05354
    boundary_name_prefix = top_sinter_spacer
    boundary_id_offset = 4
    elem_type = QUAD8
  []
  [top_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = top_sinter_spacer
    subdomain_id = 2
  []
  [top_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 30
    ny = 30
    xmax = 0.0075
    ymax = 0.03254
    ymin = 0.00254
    boundary_name_prefix= top_punch
    boundary_id_offset = 8
    elem_type = QUAD8
  []
  [top_punch_step]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 5
    xmin = 0.0075
    xmax = 0.01
    ymax = 0.00754
    ymin = 0.00254
    boundary_name_prefix= top_step
    boundary_id_offset = 12
    elem_type = QUAD8
  []
  [stitch_top_punch]
    type = StitchedMeshGenerator
    inputs = 'top_punch top_punch_step'
    stitch_boundaries_pairs = 'top_punch_right top_step_left'
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_punch'
    subdomain_id = 3
  []
  [top_punch_unified_bottom]
    type = SideSetsAroundSubdomainGenerator
    input = 'top_punch_block'
    new_boundary = 'top_punch_full_bottom'
    normal = '0 -1 0'
    block = 3
  []

  [powder]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 33
    ny = 12
    xmax = 0.01
    ymax = 0.00254
    ymin = -0.00254
    boundary_name_prefix = powder
    boundary_id_offset = 17
    elem_type = QUAD8
  []
  [powder_block]
    type = SubdomainIDGenerator
    input = powder
    subdomain_id = 4
  []

  [low_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 30
    ny = 30
    xmax = 0.0075
    ymax = -0.00254
    ymin = -0.03254
    boundary_name_prefix= low_punch
    boundary_id_offset = 21
    elem_type = QUAD8
  []
  [low_punch_step]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 5
    xmin = 0.0075
    xmax = 0.01
    ymax = -0.00254
    ymin = -0.00754
    boundary_name_prefix= low_step
    boundary_id_offset = 25
    elem_type = QUAD8
  []
  [stitch_low_punch]
    type = StitchedMeshGenerator
    inputs = 'low_punch low_punch_step'
    stitch_boundaries_pairs = 'low_punch_right low_step_left'
  []
  [low_punch_block]
    type = SubdomainIDGenerator
    input = 'stitch_low_punch'
    subdomain_id = 5
  []
  [low_punch_unified_top]
    type = SideSetsAroundSubdomainGenerator
    input = 'low_punch_block'
    new_boundary = 'low_punch_full_top'
    normal = '0 1 0'
    block = 5
  []
  [low_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmax = 0.02
    ymax = -0.03254
    ymin = -0.05354
    boundary_name_prefix = low_sinter_spacer
    boundary_id_offset = 30
    elem_type = QUAD8
  []
  [low_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = low_sinter_spacer
    subdomain_id = 6
  []
  [low_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 20
    xmax = 0.031
    ymax = -0.05354
    ymin = -0.07754
    boundary_name_prefix = low_ram_spacer
    boundary_id_offset = 34
    elem_type = QUAD8
  []
  [low_ram_spacer_block]
    type = SubdomainIDGenerator
    input = low_ram_spacer
    subdomain_id = 7
  []

  [die_wall]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 30
    ny = 45
    ymin = -0.02
    ymax = 0.02
    xmin = 0.010125
    xmax = 0.02545
    boundary_name_prefix = die_wall
    boundary_id_offset = 38
    elem_type = QUAD8
  []
  [die_wall_block]
    type = SubdomainIDGenerator
    input = die_wall
    subdomain_id = 8
  []

  [eight_blocks]
    type = MeshCollectionGenerator
    inputs = 'top_ram_spacer_block top_sinter_spacer_block top_punch_unified_bottom powder_block low_punch_unified_top low_sinter_spacer_block low_ram_spacer_block die_wall_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = eight_blocks
    old_block = '1 2 3 4 5 6 7 8'
    new_block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [exterior_punch]
    type = RenameBoundaryGenerator
    input = block_rename
    old_boundary = 'top_step_right powder_right low_step_right'
    new_boundary = 'punch_step_exterior punch_step_exterior punch_step_exterior'
  []
  patch_update_strategy = iteration
  second_order = true
  coord_type = RZ
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  converge_on = 'disp_x disp_y temperature potential'
  group_variables = 'disp_x disp_y'
[]

[Variables]
  [disp_x]
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
    order = SECOND
  []
  [disp_y]
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
    order = SECOND
  []
  [temperature]
    initial_condition = 300.0
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
    order = SECOND
  []
  [potential]
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
    order = SECOND
  []
  [temperature_top_spacers_lm]
    block = 'top_spacers_secondary_subdomain'
    order = SECOND
  []
  [potential_top_spacers_lm]
    block = 'top_spacers_secondary_subdomain'
    order = SECOND
  []
  [temperature_top_spacer_punch_lm]
    block = 'top_spacer_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_top_spacer_punch_lm]
    block = 'top_spacer_punch_secondary_subdomain'
    order = SECOND
  []
  [temperature_top_powder_lm]
    block = 'top_powder_secondary_subdomain'
    order = SECOND
  []
  [potential_top_powder_lm]
    block = 'top_powder_secondary_subdomain'
    order = SECOND
  []
  [temperature_low_powder_lm]
    block = 'low_powder_secondary_subdomain'
    order = SECOND
  []
  [potential_low_powder_lm]
    block = 'low_powder_secondary_subdomain'
    order = SECOND
  []
  [temperature_low_spacer_punch_lm]
    block = 'low_spacer_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_low_spacer_punch_lm]
    block = 'low_spacer_punch_secondary_subdomain'
    order = SECOND
  []
  [temperature_low_spacers_lm]
    block = 'low_spacers_secondary_subdomain'
    order = SECOND
  []
  [potential_low_spacers_lm]
    block = 'low_spacers_secondary_subdomain'
    order = SECOND
  []
  [temperature_punch_wall_lm]
    block = 'punch_wall_secondary_subdomain'
    order = SECOND
  []
  [potential_punch_wall_lm]
    block = 'punch_wall_secondary_subdomain'
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
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  # [current_density]
  #   family = NEDELEC_ONE
  #   order = FIRST
  #   block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer'
  # []
[]

[Modules]
  [TensorMechanics/Master]
    [graphite]
      strain = FINITE
      incremental = true
      add_variables = false
      use_automatic_differentiation = true
      extra_vector_tags = 'ref'
      generate_output = 'strain_xx strain_xy strain_yy stress_xx stress_xy stress_yy'
      additional_generate_output = 'vonmises_stress'
      additional_material_output_family = 'MONOMIAL'
      additional_material_output_order = 'FIRST'
      eigenstrain_names = graphite_thermal_expansion
      block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
    []
    [yttria]
      strain = FINITE
      incremental = true
      add_variables = false
      use_automatic_differentiation = true
      extra_vector_tags = 'ref'
      generate_output = 'strain_xx strain_xy strain_yy stress_xx stress_xy stress_yy'
      additional_generate_output = 'vonmises_stress'
      additional_material_output_family = 'MONOMIAL'
      additional_material_output_order = 'FIRST'
      eigenstrain_names = yttria_thermal_expansion
      block = 'powder'
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = potential
    diffusivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = graphite_electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []

  [HeatDiff_powder]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = yttria_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [HeatTdot_powder]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = yttria_heat_capacity
    density_name = yttria_density
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [electric_powder]
    type = ADMatDiffusion
    variable = potential
    diffusivity = yttria_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [JouleHeating_powder]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = yttria_electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'powder'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'top_ram_spacer_right top_sinter_spacer_right top_punch_right low_punch_right low_sinter_spacer_right low_ram_spacer_right die_wall_right'
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
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  # [current_density]
  #   type = ADCurrentDensity
  #   variable = current_density
  #   potential = potential

  #   block = 'top_ram_spacer top_sinter_spacer top_punch powder low_punch low_sinter_spacer low_ram_spacer die_wall'
  # []
[]

[Functions]
  [current_application]
    type = ParsedFunction
    expression = 'if(t<120.0, 0.0,
                  if(t<240.0, 3.583*(t-120.0)/(pi * 0.031 * 0.031),
                  if(t<740.0, (430.0 + 1.316*(t-240.0))/(pi * 0.031 * 0.031),
                  if(t<760.0, (1088.0 -5.05*(t-740.0))/(pi * 0.031 * 0.031),
                  if(t<790.0, 987.0/(pi * 0.031 * 0.031),
                  if(t<810.0, (987.0 -49.35*(t-790.0))/(pi * 0.031 * 0.031),
                  0.0))))))'
  []
[]

[BCs]
  [fixed_bottom_edge]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'low_ram_spacer_bottom die_wall_bottom'
  []
  [pressure_top_ram]
    type = ADPressure
    variable = disp_y
    boundary = 'top_ram_spacer_top'
    function = 'if(t<120.0, 26013.0*t, 3.1216e6)'
  []
  [fixed_centerline]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = 'top_ram_spacer_left top_sinter_spacer_left top_punch_left powder_left low_punch_left low_sinter_spacer_left low_ram_spacer_left'
  []
  [temperature_top]
    type = ADDirichletBC
    variable = temperature
    value = 300
    boundary = 'top_ram_spacer_top'
  []
  [temperature_bottom]
    type = ADDirichletBC
    variable = temperature
    value = 300
    boundary = 'low_ram_spacer_bottom'
  []
  [external_surface_temperature]
    type = CoupledVarNeumannBC
    boundary = 'top_ram_spacer_right top_sinter_spacer_right top_punch_right low_punch_right low_sinter_spacer_right low_ram_spacer_right die_wall_right' #purposefully exclude the top_step_right which will be in contact with the die
    variable = temperature
    v = heat_transfer_radiation
  []

  [electric_top]
    type = ADFunctionNeumannBC
    variable = potential
    function = 'current_application'
    boundary = 'top_ram_spacer_top'
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = potential
    value = 0.0
    boundary = 'low_ram_spacer_bottom'
  []
[]

[Contact]
  [top_spacers]
    primary = top_ram_spacer_bottom
    secondary = top_sinter_spacer_top
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [top_spacer_punch]
    primary = top_sinter_spacer_bottom
    secondary = top_punch_top
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [top_powder]
    primary = top_punch_full_bottom
    secondary = powder_top
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [low_powder]
    primary = powder_bottom
    secondary = low_punch_full_top
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [low_spacer_punch]
    primary = low_sinter_spacer_top
    secondary = low_punch_bottom
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [low_spacers]
    primary = low_ram_spacer_top
    secondary = low_sinter_spacer_bottom
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
  [punch_wall]
    primary = die_wall_left
    secondary = punch_step_exterior
    model = frictionless
    c_normal = 1e8
    # normal_lm_scaling = 1e-6
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
[]

[Constraints]
  [thermal_contact_interface_top_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_top_spacers_lm
    secondary_variable = temperature
    primary_boundary = top_ram_spacer_bottom
    primary_subdomain = top_spacers_primary_subdomain
    secondary_boundary = top_sinter_spacer_top
    secondary_subdomain = top_spacers_secondary_subdomain
    # cylinder_axis_point_1 = '0 0 0'
    # cylinder_axis_point_2 = '0 0.46 0'
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_spacers'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_top_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_top_spacers_lm
    secondary_variable = potential
    primary_boundary = top_ram_spacer_bottom
    primary_subdomain = top_spacers_primary_subdomain
    secondary_boundary = top_sinter_spacer_top
    secondary_subdomain = top_spacers_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_spacers'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  [thermal_contact_interface_top_spacer_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_top_spacer_punch_lm
    secondary_variable = temperature
    primary_boundary = top_sinter_spacer_bottom
    primary_subdomain = top_spacer_punch_primary_subdomain
    secondary_boundary = top_punch_top
    secondary_subdomain = top_spacer_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_spacer_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_top_spacer_punch]
    type = ModularGapConductanceConstraint
    variable = potential_top_spacer_punch_lm
    secondary_variable = potential
    primary_boundary = top_sinter_spacer_bottom
    primary_subdomain = top_spacer_punch_primary_subdomain
    secondary_boundary = top_punch_top
    secondary_subdomain = top_spacer_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_spacer_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  # [interface_heating_top_powder]
  #   type = ADInterfaceJouleHeatingConstraint
  #   potential_lagrange_multiplier = potential_top_powder_lm
  #   secondary_variable = temperature
  #   primary_electrical_conductivity = graphite_electrical_conductivity
  #   secondary_electrical_conductivity = yttria_electrical_conductivity
  # primary_boundary = top_punch_full_bottom
  # primary_subdomain = top_powder_primary_subdomain
  # secondary_boundary = powder_top
  # secondary_subdomain = top_powder_secondary_subdomain
  #   extra_vector_tags = 'ref'
  #   use_displaced_mesh = true
  # []
  [thermal_contact_interface_top_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_top_powder_lm
    secondary_variable = temperature
    primary_boundary = top_punch_full_bottom
    primary_subdomain = top_powder_primary_subdomain
    secondary_boundary = powder_top
    secondary_subdomain = top_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_top_powder]
    type = ModularGapConductanceConstraint
    variable = potential_top_powder_lm
    secondary_variable = potential
    primary_boundary = top_punch_full_bottom
    primary_subdomain = top_powder_primary_subdomain
    secondary_boundary = powder_top
    secondary_subdomain = top_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  # [interface_heating_bottom_punch]
  #   type = ADInterfaceJouleHeatingConstraint
  #   potential_lagrange_multiplier = potential_low_powder_lm
  #   secondary_variable = temperature
  #   primary_electrical_conductivity = yttria_electrical_conductivity
  #   secondary_electrical_conductivity = graphite_electrical_conductivity
  # primary_boundary = powder_bottom
  # primary_subdomain = low_powder_primary_subdomain
  # secondary_boundary = low_punch_full_top
  # secondary_subdomain = low_powder_secondary_subdomain
  #   extra_vector_tags = 'ref'
  #   use_displaced_mesh = true
  # []
  [thermal_contact_interface_low_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_low_powder_lm
    secondary_variable = temperature
    primary_boundary = powder_bottom
    primary_subdomain = low_powder_primary_subdomain
    secondary_boundary = low_punch_full_top
    secondary_subdomain = low_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_low_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_low_powder]
    type = ModularGapConductanceConstraint
    variable = potential_low_powder_lm
    secondary_variable = potential
    primary_boundary = powder_bottom
    primary_subdomain = low_powder_primary_subdomain
    secondary_boundary = low_punch_full_top
    secondary_subdomain = low_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_low_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  [thermal_contact_interface_low_spacer_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_low_spacer_punch_lm
    secondary_variable = temperature
    primary_boundary = low_sinter_spacer_top
    primary_subdomain = low_spacer_punch_primary_subdomain
    secondary_boundary = low_punch_bottom
    secondary_subdomain = low_spacer_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_low_spacer_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_low_spacer_punch]
    type = ModularGapConductanceConstraint
    variable = potential_low_spacer_punch_lm
    secondary_variable = potential
    primary_boundary = low_sinter_spacer_top
    primary_subdomain = low_spacer_punch_primary_subdomain
    secondary_boundary = low_punch_bottom
    secondary_subdomain = low_spacer_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_low_spacer_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  [thermal_contact_interface_low_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_low_spacers_lm
    secondary_variable = temperature
    primary_boundary = low_ram_spacer_top
    primary_subdomain = low_spacers_primary_subdomain
    secondary_boundary = low_sinter_spacer_bottom
    secondary_subdomain = low_spacers_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_low_spacers'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_low_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_low_spacers_lm
    secondary_variable = potential
    primary_boundary = low_ram_spacer_top
    primary_subdomain = low_spacers_primary_subdomain
    secondary_boundary = low_sinter_spacer_bottom
    secondary_subdomain = low_spacers_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_low_spacers'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []

  [thermal_contact_interface_punch_wall]
    type = ModularGapConductanceConstraint
    variable = temperature_punch_wall_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = punch_wall_primary_subdomain
    secondary_boundary = punch_step_exterior
    secondary_subdomain = punch_wall_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_punch_wall closed_thermal_interface_punch_wall'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact_interface_punch_wall]
    type = ModularGapConductanceConstraint
    variable = potential_punch_wall_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = punch_wall_primary_subdomain
    secondary_boundary = punch_step_exterior
    secondary_subdomain = punch_wall_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_punch_wall closed_electric_interface_punch_wall' #remember the grafoil is in this gap
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
[]

[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa
    poissons_ratio = 0.33
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [graphite_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 5.5e-6 # G535 datasheet
    stress_free_temperature = 300.0
    temperature = temperature
    eigenstrain_name = 'graphite_thermal_expansion'
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall'
  []
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = ' 1.82e3               81                           1.5e3                   5.88e4                           1.0' #from G535 datasheet
    block = 'top_ram_spacer top_sinter_spacer top_punch low_punch low_sinter_spacer low_ram_spacer die_wall top_spacers_secondary_subdomain top_spacer_punch_secondary_subdomain top_powder_secondary_subdomain low_powder_secondary_subdomain low_spacer_punch_secondary_subdomain low_spacers_secondary_subdomain punch_wall_secondary_subdomain'
  []

  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
    block = powder
  []
  [yttria_stress]
    type = ADComputeFiniteStrainElasticStress
    block = powder
  []
  [yttria_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6  # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
    eigenstrain_name = yttria_thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
    block = powder
  []
  [yttria_density]
    type = ADParsedMaterial
    property_name = 'yttria_density'
    # coupled_variables
    expression = '3106.2' ##5010.0*(1-${initial_porosity}) #in kg/m^3
    block = 'powder top_powder_secondary_subdomain low_powder_secondary_subdomain'
  []
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    expression = '3214.46 / (300.0 - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    property_name = 'yttria_thermal_conductivity'
    block = 'powder top_powder_secondary_subdomain low_powder_secondary_subdomain' #cannot be a function of temperature
  []
  [yttria_heat_capacity]
    type = ADParsedMaterial
    property_name = yttria_heat_capacity
    # coupled_variables = 'specific_heat_capacity_va'
    expression = '842.2' # at 1500K #568.73 at 1000K #447.281 # at 293K
    block = 'powder top_powder_secondary_subdomain low_powder_secondary_subdomain'
  []
  [yttria_electrical_conductivity]
    type = ADParsedMaterial
    property_name = 'yttria_electrical_conductivity'
    output_properties = yttria_electrical_conductivity
    constant_names =       'Q_elec  kB            prefactor_solid  initial_porosity   temp'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38         300.0'
    expression = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temp) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
    block = 'powder top_powder_secondary_subdomain low_powder_secondary_subdomain'
  []
  [yttria_hardness]
    type = ADParsedMaterial
    property_name = yttria_hardness
    expression = '1.0' # placeholder value that will not affect simulation results
    block = 'powder top_powder_secondary_subdomain low_powder_secondary_subdomain'
  []
[]

[UserObjects]
  [closed_thermal_interface_top_spacers]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = top_spacers_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_sinter_spacer_top
  []
  [closed_electric_interface_top_spacers]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = top_spacers_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_sinter_spacer_top
  []
  [closed_thermal_interface_top_spacer_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = top_spacer_punch_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_top
  []
  [closed_electric_interface_top_spacer_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = top_spacer_punch_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_top
  []

  [closed_thermal_interface_top_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = yttria_thermal_conductivity
    temperature = temperature
    contact_pressure = top_powder_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = yttria_hardness
    boundary = powder_top
  []
  [closed_electric_interface_top_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = yttria_electrical_conductivity
    temperature = potential
    contact_pressure = top_powder_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = yttria_hardness
    boundary = powder_top
  []

  [closed_thermal_interface_low_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = yttria_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = low_powder_normal_lm
    primary_hardness = yttria_hardness
    secondary_hardness = graphite_hardness
    boundary = low_punch_full_top
  []
  [closed_electric_interface_low_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = yttria_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = low_powder_normal_lm
    primary_hardness = yttria_hardness
    secondary_hardness = graphite_hardness
    boundary = low_punch_full_top
  []

  [closed_thermal_interface_low_spacer_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = low_spacer_punch_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = low_punch_bottom
  []
  [closed_electric_interface_low_spacer_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = low_spacer_punch_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = low_punch_bottom
  []
  [closed_thermal_interface_low_spacers]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = low_spacers_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = low_sinter_spacer_bottom
  []
  [closed_electric_interface_low_spacers]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = low_spacers_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = low_sinter_spacer_bottom
  []

  [thermal_conduction_punch_wall]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = punch_step_exterior
    gap_conductivity = 81  #assuming graphfoil thermal conductivity matches graphite
    use_displaced_mesh = true
  []
  [electrical_conduction_punch_wall]
    type = GapFluxModelConduction
    temperature = potential
    boundary = punch_step_exterior
    gap_conductivity = 5.88e4  #assuming graphfoil electrical conductivity matches graphite
    use_displaced_mesh = true
  []
  [closed_thermal_interface_punch_wall]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = punch_wall_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = punch_step_exterior
  []
  [closed_electric_interface_punch_wall]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = punch_wall_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = punch_step_exterior
  []
[]

[Postprocessors]
  [interface_heat_flux_top_ram_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_ram_spacer_top
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_top_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_sinter_spacer_bottom
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_top_punch]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_punch_right
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_low_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = low_sinter_spacer_bottom
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_low_ram_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = low_ram_spacer_top
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_low_punch]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = low_punch_right
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_die_wall]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = die_wall_right
    diffusivity = graphite_thermal_conductivity
  []

  [interface_electrical_flux_top_ram_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_ram_spacer_top
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_top_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_sinter_spacer_bottom
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_top_punch]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_punch_right
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_low_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = low_sinter_spacer_top
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_low_ram_spacer]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = low_ram_spacer_bottom
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_low_punch]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = low_punch_right
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_die_wall]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = die_wall_right
    diffusivity = graphite_electrical_conductivity
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = false
  line_search = 'none'

  # # force running options
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # mortar contact solver options
  petsc_options = '-snes_converged_reason -pc_svd_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type'
  petsc_options_value = ' lu       superlu_dist'
  snesmf_reuse_base = false

  nl_rel_tol = 1e-6 #1e-6 #1e-8 couldn't converge with 1e-3 dt in the first timestep in 20 nl iterations
  nl_abs_tol = 1e-8 # couldn't converge past the first timestep on temperature #1e-10
  nl_max_its = 20
  nl_forced_its = 2
  l_max_its = 50

  dtmax = 100
  end_time = 1200
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    optimal_iterations = 8
    iteration_window = 2
    time_t = ' 0.0     120.0     240.0   740.0   760.0   790.0   810.0'  #using this approach to force each inflection point in the current function
    time_dt = '0.05    5.0e-3   10.0     1.0     1.0     5.0     0.25'
  []
[]

[Outputs]
  color = false
  csv = true
  exodus = true
  perf_graph = true
[]

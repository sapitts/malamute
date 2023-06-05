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
    ymin = 0.051
    ymax = 0.075
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
    ymin = 0.03
    ymax = 0.051
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
    ymax = 0.03
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
    ymax = 0.005
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

  [three_blocks]
    type = MeshCollectionGenerator
    inputs = 'top_ram_spacer_block top_sinter_spacer_block top_punch_unified_bottom'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = three_blocks
    old_block = '1 2 3'
    new_block = 'top_ram_spacer top_sinter_spacer top_punch'
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
    block = 'top_ram_spacer top_sinter_spacer top_punch'
    order = SECOND
  []
  [disp_y]
    block = 'top_ram_spacer top_sinter_spacer top_punch'
    order = SECOND
  []
  [temperature]
    initial_condition = 300.0
    block = 'top_ram_spacer top_sinter_spacer top_punch'
    order = SECOND
  []
  [potential]
    block = 'top_ram_spacer top_sinter_spacer top_punch'
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
[]

[AuxVariables]
  [heat_transfer_radiation]
    order = SECOND
  []

  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  # [current_density]
  #   family = NEDELEC_ONE
  #   order = FIRST
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
      block = 'top_ram_spacer top_sinter_spacer top_punch'
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = potential
    diffusivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = graphite_electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'top_ram_spacer_right top_sinter_spacer_right top_punch_right'
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
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  # [current_density]
  #   type = ADCurrentDensity
  #   variable = current_density
  #   potential = potential
  #   block = 'top_ram_spacer top_sinter_spacer top_punch'
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
    boundary = 'top_punch_full_bottom'
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
    boundary = 'top_ram_spacer_left top_sinter_spacer_left top_punch_left'
  []
  [temperature_top]
    type = ADDirichletBC
    variable = temperature
    value = 300
    boundary = 'top_ram_spacer_top'
  []
  # [temperature_bottom]
  #   type = ADDirichletBC
  #   variable = temperature
  #   value = 300
  #   boundary = 'top_punch_full_bottom'
  # []
  [external_surface_temperature]
    type = CoupledVarNeumannBC
    boundary = 'top_ram_spacer_right top_sinter_spacer_right top_punch_right' #purposefully exclude the top_step_right which will be in contact with the die
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
    boundary = 'top_punch_full_bottom'
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
  # [interface_heating]
  #   type = ADInterfaceJouleHeatingConstraint
  #   potential_lagrange_multiplier = potential_interface_lm
  #   secondary_variable = temperature
  #   primary_electrical_conductivity = graphite_electrical_conductivity
  #   secondary_electrical_conductivity = graphite_electrical_conductivity
  #   primary_boundary = top_ram_spacer_bottom
  #   primary_subdomain = interface_primary_subdomain
  #   secondary_boundary = top_sinter_spacer_top
  #   secondary_subdomain = interface_secondary_subdomain
  #   extra_vector_tags = 'ref'
  #   use_displaced_mesh = true
  # []
[]

[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, 68 GPa, aluminum
    poissons_ratio = 0.33
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [graphite_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 5.5e-6 # G535 datasheet
    stress_free_temperature = 300.0
    temperature = temperature
    eigenstrain_name = 'graphite_thermal_expansion'
    block = 'top_ram_spacer top_sinter_spacer top_punch'
  []
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = ' 1.82e3               81                           1.5e3                   5.88e4                           1.0' #from G535 datasheet
    block = 'top_ram_spacer top_sinter_spacer top_punch top_spacers_secondary_subdomain top_spacer_punch_secondary_subdomain'
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
[]

[Postprocessors]
  [interface_heat_flux_large_block]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_sinter_spacer_top
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_small_block]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_ram_spacer_bottom
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_punch]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = top_punch_right
    diffusivity = graphite_thermal_conductivity
  []
  [interface_electrical_flux_large_block]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_sinter_spacer_top
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_small_block]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_ram_spacer_bottom
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_punch]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = top_punch_right
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
  nl_forced_its = 1
  l_max_its = 50

  dtmax = 100
  end_time = 1200
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.25
    optimal_iterations = 8
    iteration_window = 2
    time_t = ' 0.0   120.0     240.0   740.0   760.0   790.0   810.0'  #using this approach to force each inflection point in the current function
    time_dt = '0.25    5.0e-3   10.0     1.0     1.0     5.0     0.25'
  []
[]

[Outputs]
  color = false
  csv = true
  exodus = true
  perf_graph = true
[]

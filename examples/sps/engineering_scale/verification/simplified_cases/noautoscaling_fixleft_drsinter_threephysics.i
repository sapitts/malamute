## Units in the input file: m-Pa-s-K-V

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
[]

[Mesh]
  [left_rectangle]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 51
    xmax = 0.1
    ymin = 0.0
    ymax = 0.1
    boundary_name_prefix = moving_block
    elem_type = QUAD8
  []
  [left_block]
    type = SubdomainIDGenerator
    input = left_rectangle
    subdomain_id = 1
  []
  [right_rectangle]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 50
    xmin = 0.1
    xmax = 0.2
    ymin = 0
    ymax = 0.1
    boundary_name_prefix = fixed_block
    boundary_id_offset = 4
    elem_type = QUAD8
  []
  [right_block]
    type = SubdomainIDGenerator
    input = right_rectangle
    subdomain_id = 2
  []
  [two_blocks]
    type = MeshCollectionGenerator
    inputs = 'left_block right_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = two_blocks
    old_block = '1 2'
    new_block = 'left_block right_block'
  []
  patch_update_strategy = iteration
  second_order = true
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
    block = 'left_block right_block'
    order = SECOND
  []
  [disp_y]
    block = 'left_block right_block'
    order = SECOND
  []
  [temperature]
    initial_condition = 300.0
    block = 'left_block right_block'
    order = SECOND
  []
  [potential]
    block = 'left_block right_block'
    order = SECOND
  []
  [temperature_interface_lm]
    block = 'interface_secondary_subdomain'
    order = SECOND
  []
  [potential_interface_lm]
    block = 'interface_secondary_subdomain'
    order = SECOND
  []
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
      block = 'left_block right_block'
    []
  []
[]

[Kernels]
  [HeatDiff_aluminum]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'left_block right_block'
  []
  [HeatTdot_aluminum]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'left_block right_block'
  []
  [electric_aluminum]
    type = ADMatDiffusion
    variable = potential
    diffusivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'left_block right_block'
  []
  [JouleHeating_alumnium]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = graphite_electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'left_block right_block'
  []
[]

[BCs]
  [fixed_bottom_edge]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'moving_block_bottom fixed_block_bottom'
  []
  # [fixed_right_block]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   value = 0
  #   boundary = 'fixed_block_right'
  # []
  # [pressure_left_block]
  #   type = ADPressure
  #   variable = disp_x
  #   boundary = 'moving_block_left'
  #   function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  # []
  [fixed_left_block]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = 'moving_block_left'
  []
  [pressure_right_block]
    type = ADPressure
    variable = disp_x
    boundary = 'fixed_block_right'
    function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  []
  [temperature_left]
    type = ADDirichletBC
    variable = temperature
    value = 300
    boundary = 'moving_block_left'
  []
  [temperature_right]
    type = ADDirichletBC
    variable = temperature
    value = 300
    boundary = 'fixed_block_right'
  []

  [electric_left]
    type = ADDirichletBC
    variable = potential
    value = 0.0
    boundary = moving_block_left
  []
  [electric_right]
    type = ADFunctionDirichletBC
    variable = potential
    function = 'if(t<80.0, 2.5e-2*t, 2.0)'
    boundary = fixed_block_right
  []
[]

[Contact]
  [interface]
    primary = moving_block_right
    secondary = fixed_block_left
    model = frictionless
    formulation = mortar
    correct_edge_dropping = true
    use_dual = true
  []
[]

[Constraints]
  [thermal_contact]
    type = ModularGapConductanceConstraint
    variable = temperature_interface_lm
    secondary_variable = temperature
    primary_boundary = moving_block_right
    primary_subdomain = interface_primary_subdomain
    secondary_boundary = fixed_block_left
    secondary_subdomain = interface_secondary_subdomain
    gap_flux_models = 'closed_thermal'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [electrical_contact]
    type = ModularGapConductanceConstraint
    variable = potential_interface_lm
    secondary_variable = potential
    primary_boundary = moving_block_right
    primary_subdomain = interface_primary_subdomain
    secondary_boundary = fixed_block_left
    secondary_subdomain = interface_secondary_subdomain
    gap_flux_models = 'closed_electric'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    use_displaced_mesh = true
  []
  [interface_heating]
    type = ADInterfaceJouleHeatingConstraint
    potential_lagrange_multiplier = potential_interface_lm
    secondary_variable = temperature
    primary_electrical_conductivity = graphite_electrical_conductivity
    secondary_electrical_conductivity = graphite_electrical_conductivity
    primary_boundary = moving_block_right
    primary_subdomain = interface_primary_subdomain
    secondary_boundary = fixed_block_left
    secondary_subdomain = interface_secondary_subdomain
    extra_vector_tags = 'ref'
    use_displaced_mesh = true
  []
[]

[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, 68 GPa, aluminum
    poissons_ratio = 0.33
    block = 'left_block right_block'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'left_block right_block'
  []
  [graphite_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 5.5e-6 # aluminum
    stress_free_temperature = 300.0
    temperature = temperature
    eigenstrain_name = 'graphite_thermal_expansion'
    block = 'left_block right_block'
  []
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = ' 1.82e3               81                           1.5e3                   5.88e4                           1.0' #from G535 datasheet
    block = 'left_block right_block interface_secondary_subdomain'
  []
[]

[UserObjects]
  [closed_thermal]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = moving_block_right
  []
  [closed_electric]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = moving_block_right
  []
[]

[Postprocessors]
  [interface_heat_flux_large_block]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = fixed_block_left
    diffusivity = graphite_thermal_conductivity
  []
  [interface_heat_flux_small_block]
    type = ADSideDiffusiveFluxAverage
    variable = temperature
    boundary = moving_block_right
    diffusivity = graphite_thermal_conductivity
  []
  [interface_electrical_flux_large_block]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = fixed_block_left
    diffusivity = graphite_electrical_conductivity
  []
  [interface_electrical_flux_small_block]
    type = ADSideDiffusiveFluxAverage
    variable = potential
    boundary = moving_block_right
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
  nl_abs_tol = 1e-8 #1e-16 couldn't converge past the first timestep on temperature #1e-10
  nl_max_its = 20
  nl_forced_its = 2
  l_max_its = 50

  dtmax = 100
  end_time = 680
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0e-3
    optimal_iterations = 8
    iteration_window = 2
  []
[]

[Outputs]
  color = false
  csv = true
  exodus = true
  perf_graph = true
[]

## Parameters for the standard DCS-5 geometry to build the mesh, units in meters
cup_r = 0.031 # previously was ram_spacer_r
cup_h = 0.020 # previously was ram_spacer_height
cup_inset_ID = 0.042 # modified from 0.0415 to facilitate consistent node alignment and sure mesh builds successfully
cup_overhang_height = 0.002 # previously was ram_spacer_overhang_height
CFC_radius = 0.020 # previously was cc_spacer_radius
CFC_height = 0.00635 # previously was cc_spacer_heightt

spacer_radius = 0.020 # previously was sinter_spacer_radius
spacer_height = 0.02235 # previously was sinter_spacer_height
#spacer_overhang_radius = 0.0135 ## is less than the 13.55 that actually exists to facilitate node matching in mesh building step
spacer_inset_ID = 0.022 #modified from 0.0215 to faciliate consistent node alignment
# previously was sinter_spacer_overhang_radiuss
spacer_overhang_height = 0.002 # previously was sinter_spacer_overhang_height

punch_radius = 0.010
punch_height = 0.030

sample_radius = 0.010 # was powder_radius
sample_height = 0.010 # was powder_height

die_wall_height = 0.040
die_wall_inner_radius = 0.010
die_wall_thickness = 0.017

contact_scale_factor = 1.0e-7

#######################################################################################
### Calculated values from user-provided results
cup_surface_area = ${fparse pi * cup_r * cup_r} # was ram_spacer_area
# ram_spacer_overhang_offset = ${fparse cup_inset_ID/2}

####
# These are the y-pos of the interface for the bottom stack
y_pos_CFC_spacer_interface = ${fparse cup_h + CFC_height} # this was ram_cc_spacers_height
y_pos_spacer_punch_interface = ${fparse y_pos_CFC_spacer_interface + spacer_height} # was ram_cc_sinter_spacers_height
y_pos_bot_punch_sample_interface = ${fparse y_pos_spacer_punch_interface + punch_height} # was ram_cc_sinter_spacers_punch_height
y_pos_sample_top_punch_interface = ${fparse y_pos_bot_punch_sample_interface + sample_height} # was stack_with_powder

die_wall_outer_radius = ${fparse die_wall_inner_radius + die_wall_thickness}

[Mesh]
  [bot_cup] # was bot_ram_spacer
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${cup_r}
    ymax = ${cup_h}
    boundary_name_prefix = bot_cup
    elem_type = QUAD8
  []
  [bot_cup_overhang] # was bot_ram_overhang
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse cup_inset_ID/2}
    xmax = ${cup_r}
    ymin = ${cup_h}
    ymax = ${fparse cup_h + cup_overhang_height}
    boundary_name_prefix = bot_cup_overhang
    elem_type = QUAD8
  []
  [stitch_bot_cup]
    type = StitchMeshGenerator
    inputs = 'bot_cup bot_cup_overhang'
    stitch_boundaries_pairs = 'bot_cup_top bot_cup_overhang_bottom'
  []
  [bot_cup_block]
    type = SubdomainIDGenerator
    input = 'stitch_bot_cup'
    subdomain_id = '1'
  []
  [bot_CFC]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${CFC_radius}
    ymin = ${cup_h}
    ymax = ${y_pos_CFC_spacer_interface}
    boundary_name_prefix = 'bot_CFC'
    boundary_id_offset = 8
    elem_type = QUAD8
  []
  [bot_CFC_block] # was bottom_cc_spacer_block_
    type = SubdomainIDGenerator
    input = 'bot_CFC'
    subdomain_id = '2'
  []
  [bot_spacer] # was bottom_sinter_spacer
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${spacer_radius}
    ymin = ${y_pos_CFC_spacer_interface}
    ymax = ${y_pos_spacer_punch_interface}
    boundary_name_prefix = bot_spacer
    boundary_id_offset = 12
    elem_type = QUAD8
  []
  [bot_spacer_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 18 #better to have node alignment
    ny = 2
    xmin = ${fparse spacer_inset_ID/2}
    xmax = ${spacer_radius}
    ymin = ${y_pos_spacer_punch_interface}
    ymax = ${fparse y_pos_spacer_punch_interface + spacer_overhang_height}
    boundary_name_prefix = bot_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 16
  []
  [stitch_bot_spacer]
    type = StitchMeshGenerator
    inputs = 'bot_spacer bot_spacer_overhang'
    stitch_boundaries_pairs = 'bot_spacer_top bot_spacer_overhang_bottom'
  []
  [bot_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bot_spacer'
    subdomain_id = '3'
  []
  [bot_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${y_pos_spacer_punch_interface}
    ymax = ${y_pos_bot_punch_sample_interface}
    boundary_name_prefix = 'bot_punch'
    elem_type = QUAD8
    boundary_id_offset = 20
  []
  [bot_punch_block]
    type = SubdomainIDGenerator
    input = bot_punch
    subdomain_id = 4
  []

  [sample]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 15
    ny = 18
    xmax = ${sample_radius}
    ymin = ${y_pos_bot_punch_sample_interface}
    ymax = ${y_pos_sample_top_punch_interface}
    boundary_name_prefix = sample
    elem_type = QUAD8
    boundary_id_offset = 24
  []
  [sample_block]
    type = SubdomainIDGenerator
    input = sample
    subdomain_id = 5
  []

  [top_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${y_pos_sample_top_punch_interface}
    ymax = ${fparse y_pos_sample_top_punch_interface + punch_height}
    boundary_name_prefix = 'top_punch'
    elem_type = QUAD8
    boundary_id_offset = 28
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = top_punch
    subdomain_id = 6
  []
  [top_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${spacer_radius}
    ymin = ${fparse y_pos_sample_top_punch_interface + punch_height}
    ymax = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - y_pos_CFC_spacer_interface}
    boundary_name_prefix = top_spacer
    boundary_id_offset = 32
    elem_type = QUAD8
  []
  [top_spacer_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 18
    ny = 2
    xmin = ${fparse spacer_inset_ID/2}
    xmax = ${spacer_radius}
    ymin = ${fparse y_pos_sample_top_punch_interface + punch_height - spacer_overhang_height}
    ymax = ${fparse y_pos_sample_top_punch_interface + punch_height}
    boundary_name_prefix = top_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 36
  []
  [stitch_top_spacer]
    type = StitchMeshGenerator
    inputs = 'top_spacer top_spacer_overhang'
    stitch_boundaries_pairs = 'top_spacer_bottom top_spacer_overhang_top'
  []
  [top_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_spacer'
    subdomain_id = '7'
  []
  [top_CFC]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${CFC_radius}
    ymin = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - y_pos_CFC_spacer_interface}
    ymax = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - cup_h}
    boundary_name_prefix = 'top_CFC'
    boundary_id_offset = 40
    elem_type = QUAD8
  []
  [top_CFC_block]
    type = SubdomainIDGenerator
    input = 'top_CFC'
    subdomain_id = '8'
  []
  [top_cup]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${cup_r}
    ymin = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - cup_h}
    ymax = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface}
    boundary_name_prefix = top_cup
    elem_type = QUAD8
    boundary_id_offset = 44
  []
  [top_cup_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse cup_inset_ID/2}
    xmax = ${cup_r}
    ymin = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - cup_h - cup_overhang_height}
    ymax = ${fparse y_pos_sample_top_punch_interface + y_pos_bot_punch_sample_interface - cup_h}
    boundary_name_prefix = top_cup_overhang
    elem_type = QUAD8
    boundary_id_offset = 48
  []
  [stitch_top_cup]
    type = StitchMeshGenerator
    inputs = 'top_cup top_cup_overhang'
    stitch_boundaries_pairs = 'top_cup_bottom top_cup_overhang_top'
  []
  [top_cup_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_cup'
    subdomain_id = '9'
  []

  [die]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 14
    ny = 30
    xmin = ${die_wall_inner_radius}
    xmax = ${die_wall_outer_radius}
    ymin = ${fparse y_pos_bot_punch_sample_interface + (sample_height - die_wall_height) / 2.0}
    ymax = ${fparse y_pos_bot_punch_sample_interface + (sample_height + die_wall_height) / 2.0}
    boundary_name_prefix = die
    elem_type = QUAD8
    boundary_id_offset = 52
  []
  [die_block]
    type = SubdomainIDGenerator
    input = 'die'
    subdomain_id = 10
  []

  [ten_blocks]
    type = MeshCollectionGenerator
    inputs = 'bot_cup_block bot_CFC_block bot_spacer_block
              bot_punch_block sample_block top_punch_block top_spacer_block
              top_CFC_block top_cup_block die_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = ten_blocks
    old_block = '1 2 3 4 5 6 7 8 9 10'
    new_block = 'bot_cup bot_CFC bot_spacer bot_punch
                 sample top_punch top_spacer top_CFC top_cup die'
  []

  [uncovered_bot_punch_right]
    type = SideSetsFromBoundingBoxGenerator
    input = block_rename
    bottom_left = '${fparse punch_radius - 1.0e-3} ${fparse y_pos_spacer_punch_interface + spacer_overhang_height + 1.0e-4} 0.0'
    top_right = '${fparse punch_radius + 1.0e-3} ${fparse y_pos_bot_punch_sample_interface + (sample_height - die_wall_height) / 2.0 - 1.0e-4} 0.0'
    boundary_new = 'uncovered_bot_punch_right'
    included_boundaries = 'bot_punch_right'
  []
  [uncovered_top_punch_right]
    type = SideSetsFromBoundingBoxGenerator
    input = uncovered_bot_punch_right
    bottom_left = '${fparse punch_radius - 1.0e-3} ${fparse y_pos_bot_punch_sample_interface + (sample_height + die_wall_height) / 2.0 + 1.0e-4} 0.0'
    top_right = '${fparse punch_radius + 1.0e-3} ${fparse y_pos_sample_top_punch_interface + punch_height - spacer_overhang_height - 1.0e-4} 0.0'
    boundary_new = 'uncovered_top_punch_right'
    included_boundaries = 'top_punch_right'
  []
    # For the primary domains, the suffix "_B" refers to the bottom boundary of the component
    # For the secondary domains, the suffix "_A" refers to the top boundary of the component

    [bot_cup_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_cup_top'
    new_block_id = 111
    new_block_name = 'bot_cup_A_primary'
    input = uncovered_top_punch_right
  []
  [bot_CFC_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_CFC_bottom'
    new_block_id = 212
    new_block_name = 'bot_CFC_B_secondary'
    input = bot_cup_A_primary
  []
  [bot_CFC_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_CFC_top'
    new_block_id = 211
    new_block_name = 'bot_CFC_A_primary'
    input = bot_CFC_B_secondary
  []
  [bot_spacer_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_spacer_bottom'
    new_block_id = 312
    new_block_name = 'bot_spacer_B_secondary'
    input = bot_CFC_A_primary
  []
  [bot_spacer_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_spacer_top'
    new_block_id = 311
    new_block_name = 'bot_spacer_A_primary'
    input = bot_spacer_B_secondary
  []
  [bot_punch_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_punch_bottom'
    new_block_id = 412
    new_block_name = 'bot_punch_B_secondary'
    input = bot_spacer_A_primary
  []
  [bot_punch_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_punch_top'
    new_block_id = 411
    new_block_name = 'bot_punch_A_primary'
    input = bot_punch_B_secondary
  []
  [sample_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'sample_bottom'
    new_block_id = 512
    new_block_name = 'sample_B_secondary'
    input = bot_punch_A_primary
  []

  [sample_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'sample_top'
    new_block_id = 511
    new_block_name = 'sample_A_primary'
    input = sample_B_secondary
  []
  [top_punch_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_bottom'
    new_block_id = 612
    new_block_name = 'top_punch_B_secondary'
    input = sample_A_primary
  []
  [top_punch_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_top'
    new_block_id = 611
    new_block_name = 'top_punch_A_primary'
    input = top_punch_B_secondary
  []
  [top_spacer_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_spacer_bottom'
    new_block_id = 712
    new_block_name = 'top_spacer_B_secondary'
    input = top_punch_A_primary
  []
  [top_spacer_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_spacer_top'
    new_block_id = 711
    new_block_name = 'top_spacer_A_primary'
    input = top_spacer_B_secondary
  []
  [top_CFC_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_CFC_bottom'
    new_block_id = 812
    new_block_name = 'top_CFC_B_secondary'
    input = top_spacer_A_primary
  []
  [top_CFC_A_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_CFC_top'
    new_block_id = 811
    new_block_name = 'top_CFC_A_primary'
    input = top_CFC_B_secondary
  []
  [top_cup_B_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_cup_bottom'
    new_block_id = 912
    new_block_name = 'top_cup_B_secondary'
    input = top_CFC_A_primary
  []

  [die_ID_primary] # This was die_ID_primary
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'die_left'
    new_block_id = 1013
    new_block_name = 'die_ID_primary'
    input = top_cup_B_secondary
  []
  [bot_punch_OD_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_punch_right'
    new_block_id = 414
    new_block_name = 'bot_punch_OD_secondary'
    input = die_ID_primary
  []
  [sample_OD_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'sample_right'
    new_block_id = 514
    new_block_name = 'sample_OD_secondary'
    input = bot_punch_OD_secondary
  []
  [top_punch_OD_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_right'
    new_block_id = 614
    new_block_name = 'top_punch_OD_secondary'
    input = sample_OD_secondary
  []

  [bot_spacer_overhang_top_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bot_spacer_overhang_top'
    new_block_id = 3111
    new_block_name = 'bot_spacer_overhang_top_primary'
    input = top_punch_OD_secondary
  []
  [gap_die_bottom_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'die_bottom'
    new_block_id = 1022
    new_block_name = 'gap_die_bottom_secondary'
    input = bot_spacer_overhang_top_primary
  []
  [gap_top_spacer_overhang_bottom_primary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_spacer_overhang_bottom'
    new_block_id = 7222
    new_block_name = 'gap_top_spacer_overhang_bottom_primary'
    input = gap_die_bottom_secondary
  []
  [gap_die_top_secondary]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'die_top'
    new_block_id = 1011
    new_block_name = 'gap_die_top_secondary'
    input = gap_top_spacer_overhang_bottom_primary
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
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
    order = SECOND
  []
  [potential]
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
    order = SECOND
  []
  [temperature_bot_CFC_B_lm]
    block = 'bot_CFC_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_bot_CFC_B_lm]
    block = 'bot_CFC_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_bot_spacer_lm]
    block = 'bot_spacer_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_bot_spacer_lm]
    block = 'bot_spacer_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_bot_punch_lm]
    block = 'bot_punch_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_bot_punch_lm]
    block = 'bot_punch_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_sample_lm]
    block = 'sample_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_sample_lm]
    block = 'sample_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_top_punch_lm]
    block = 'top_punch_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_top_punch_lm]
    block = 'top_punch_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_top_spacer_lm]
    block = 'top_spacer_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_top_spacer_lm]
    block = 'top_spacer_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_top_CFC_lm]
    block = 'top_CFC_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_top_CFC_lm]
    block = 'top_CFC_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_top_cup_lm]
    block = 'top_cup_B_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_top_cup_lm]
    block = 'top_cup_B_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_bot_punch_OD_lm]
    block = 'bot_punch_OD_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_bot_punch_OD_lm]
    block = 'bot_punch_OD_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_sample_OD_lm]
    block = 'sample_OD_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_sample_OD_lm]
    block = 'sample_OD_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_top_punch_OD_lm]
    block = 'top_punch_OD_secondary'
    order = SECOND
    use_dual = true
  []
  [potential_top_punch_OD_lm]
    block = 'top_punch_OD_secondary'
    order = SECOND
    use_dual = true
  []

  [temperature_gap_die_top_lm]
    block = 'gap_die_top_secondary'
    order = SECOND
    use_dual = true
  []
  [temperature_gap_die_bottom_lm]
    block = 'gap_die_bottom_secondary'
    order = SECOND
    use_dual = true
  []
[]

[AuxVariables]
  [heat_transfer_radiation]
    order = SECOND
  []

  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
  []

  [interface_spacer_components_lm]
    order = FIRST
    family = LAGRANGE
    block = 'bot_CFC_B_secondary bot_spacer_B_secondary
             top_CFC_B_secondary top_cup_B_secondary'
    initial_condition = '${fparse contact_scale_factor * (961 * 9.8067) / (pi * CFC_radius * CFC_radius)}'
  []
  [interface_punch_components_lm]
    order = FIRST
    family = LAGRANGE
    block = 'bot_punch_B_secondary sample_B_secondary top_punch_B_secondary top_spacer_B_secondary'
    initial_condition = '${fparse contact_scale_factor * (961 * 9.8067) / (pi * punch_radius * punch_radius)}'
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die'
  []
  [electric_graphite]
    type = ADHeatConduction
    variable = potential
    thermal_conductivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = graphite_electric_field_heating
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die'
  []

  [HeatDiff_anistropic_carbon_fiber]
    type = ADMatAnisoDiffusion
    diffusivity = CFC_anisotropic_thermal_conductivity_matrix
    variable = temperature
    extra_vector_tags = 'ref'
    block = 'bot_CFC top_CFC'
  []
  [HeatTdot_carbon_fiber]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = CFC_heat_capacity
    density_name = CFC_density
    extra_vector_tags = 'ref'
    block = 'bot_CFC top_CFC'
  []
  [electric_carbon_fiber]
    type = ADHeatConduction
    variable = potential
    thermal_conductivity = CFC_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bot_CFC top_CFC'
  []
  [JouleHeating_carbon_fiber]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = CFC_electric_field_heating
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bot_CFC top_CFC'
  []

  [HeatDiff_powder]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = SS316_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'sample'
  []
  [HeatTdot_powder]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = SS316_heat_capacity
    density_name = SS316_density
    extra_vector_tags = 'ref'
    block = 'sample'
  []
  [electric_powder]
    type = ADHeatConduction
    variable = potential
    thermal_conductivity = SS316_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'sample'
  []
  [JouleHeating_powder]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = SS316_electric_field_heating
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'sample'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'bot_cup_right bot_cup_overhang_right bot_CFC_right
                bot_spacer_right bot_spacer_overhang_right uncovered_bot_punch_right
                top_spacer_overhang_right top_spacer_right die_right uncovered_top_punch_right
                top_CFC_right top_cup_overhang_right top_cup_right'
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
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'bot_cup bot_CFC bot_spacer bot_punch
             sample top_punch top_spacer top_CFC top_cup die'
  []
[]

[Functions]
  [current_application]
    type = PiecewiseLinear
    x = '0            40                                    60                                   160                                   200                                   230                                   340                                   850                                   890                                   900                                   950                                   1010                                  1050                                  1100                                  1200                                  1240                                1250                        1260 1800'
    y = '0  ${fparse 561/cup_surface_area} ${fparse 502/cup_surface_area} ${fparse 500/cup_surface_area} ${fparse 417/cup_surface_area} ${fparse 417/cup_surface_area} ${fparse 566/cup_surface_area} ${fparse 952/cup_surface_area} ${fparse 926/cup_surface_area} ${fparse 926/cup_surface_area} ${fparse 977/cup_surface_area}  ${fparse 902/cup_surface_area} ${fparse 902/cup_surface_area} ${fparse 927/cup_surface_area} ${fparse 926/cup_surface_area} ${fparse 903/cup_surface_area} ${fparse 4/cup_surface_area}  0    0'
    scale_factor = 1.0
  []
[]

[BCs]
  [temperature_rams]
    type = ADDirichletBC
    variable = temperature
    value = 300.0
    boundary = 'top_cup_top bot_cup_bottom'
  []
  [external_surface_temperature]
    type = CoupledVarNeumannBC
    variable = temperature
    v = heat_transfer_radiation
    boundary = 'bot_cup_right bot_cup_overhang_right bot_CFC_right
                bot_spacer_right bot_spacer_overhang_right uncovered_bot_punch_right
                top_spacer_overhang_right top_spacer_right die_right uncovered_top_punch_right
                top_CFC_right top_cup_overhang_right top_cup_right'
  []
  [electric_bottom]
    type = ADFunctionNeumannBC
    variable = potential
    function = 'current_application'
    boundary = 'bot_cup_bottom'
  []
  [electric_top]
    type = ADDirichletBC
    variable = potential
    value = 0.0
    boundary = 'top_cup_top'
  []
[]

[Constraints]
  [thermal_contact_interface_bot_cup_bot_CFC]
    type = ModularGapConductanceConstraint
    variable = temperature_bot_CFC_B_lm
    secondary_variable = temperature
    primary_boundary = bot_cup_top
    primary_subdomain = bot_cup_A_primary
    secondary_boundary = bot_CFC_bottom
    secondary_subdomain = bot_CFC_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bot_cup_bot_CFC'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_bot_cup_bot_CFC]
    type = ModularGapConductanceConstraint
    variable = potential_bot_CFC_B_lm
    secondary_variable = potential
    primary_boundary = bot_cup_top
    primary_subdomain = bot_cup_A_primary
    secondary_boundary = bot_CFC_bottom
    secondary_subdomain = bot_CFC_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bot_cup_bot_CFC'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_bot_CFC_bot_spacer]
    type = ModularGapConductanceConstraint
    variable = temperature_bot_spacer_lm
    secondary_variable = temperature
    primary_boundary = bot_CFC_top
    primary_subdomain = bot_CFC_A_primary
    secondary_boundary = bot_spacer_bottom
    secondary_subdomain = bot_spacer_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bot_CFC_bot_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_bot_CFC_bot_spacer]
    type = ModularGapConductanceConstraint
    variable = potential_bot_spacer_lm
    secondary_variable = potential
    primary_boundary = bot_CFC_top
    primary_subdomain = bot_CFC_A_primary
    secondary_boundary = bot_spacer_bottom
    secondary_subdomain = bot_spacer_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bot_CFC_bot_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_bot_spacer_bot_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_bot_punch_lm
    secondary_variable = temperature
    primary_boundary = bot_spacer_top
    primary_subdomain = bot_spacer_A_primary
    secondary_boundary = bot_punch_bottom
    secondary_subdomain = bot_punch_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bot_spacer_bot_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_bot_spacer_bot_punch]
    type = ModularGapConductanceConstraint
    variable = potential_bot_punch_lm
    secondary_variable = potential
    primary_boundary = bot_spacer_top
    primary_subdomain = bot_spacer_A_primary
    secondary_boundary = bot_punch_bottom
    secondary_subdomain = bot_punch_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bot_spacer_bot_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_bot_punch_sample]
    type = ModularGapConductanceConstraint
    variable = temperature_sample_lm
    secondary_variable = temperature
    primary_boundary = bot_punch_top
    primary_subdomain = bot_punch_A_primary
    secondary_boundary = sample_bottom
    secondary_subdomain = sample_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bot_punch_sample'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_bot_punch_sample]
    type = ModularGapConductanceConstraint
    variable = potential_sample_lm
    secondary_variable = potential
    primary_boundary = bot_punch_top
    primary_subdomain = bot_punch_A_primary
    secondary_boundary = sample_bottom
    secondary_subdomain = sample_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bot_punch_sample'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_sample_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_top_punch_lm
    secondary_variable = temperature
    primary_boundary = sample_top
    primary_subdomain = sample_A_primary
    secondary_boundary = top_punch_bottom
    secondary_subdomain = top_punch_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_sample_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_sample_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_top_punch_lm
    secondary_variable = potential
    primary_boundary = sample_top
    primary_subdomain = sample_A_primary
    secondary_boundary = top_punch_bottom
    secondary_subdomain = top_punch_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_sample_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_punch_top_spacer]
    type = ModularGapConductanceConstraint
    variable = temperature_top_spacer_lm
    secondary_variable = temperature
    primary_boundary = top_punch_top
    primary_subdomain = top_punch_A_primary
    secondary_boundary = top_spacer_bottom
    secondary_subdomain = top_spacer_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_punch_top_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_punch_top_spacer]
    type = ModularGapConductanceConstraint
    variable = potential_top_spacer_lm
    secondary_variable = potential
    primary_boundary = top_punch_top
    primary_subdomain = top_punch_A_primary
    secondary_boundary = top_spacer_bottom
    secondary_subdomain = top_spacer_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_punch_top_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_spacer_top_CFC]
    type = ModularGapConductanceConstraint
    variable = temperature_top_CFC_lm
    secondary_variable = temperature
    primary_boundary = top_spacer_top
    primary_subdomain = top_spacer_A_primary
    secondary_boundary = top_CFC_bottom
    secondary_subdomain = top_CFC_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_spacer_top_CFC'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_spacer_top_CFC]
    type = ModularGapConductanceConstraint
    variable = potential_top_CFC_lm
    secondary_variable = potential
    primary_boundary = top_spacer_top
    primary_subdomain = top_spacer_A_primary
    secondary_boundary = top_CFC_bottom
    secondary_subdomain = top_CFC_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_spacer_top_CFC'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_CFC_top_cup]
    type = ModularGapConductanceConstraint
    variable = temperature_top_cup_lm
    secondary_variable = temperature
    primary_boundary = top_CFC_top
    primary_subdomain = top_CFC_A_primary
    secondary_boundary = top_cup_bottom
    secondary_subdomain = top_cup_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_inteface_top_CFC_top_cup'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_CFC_top_cup]
    type = ModularGapConductanceConstraint
    variable = potential_top_cup_lm
    secondary_variable = potential
    primary_boundary = top_CFC_top
    primary_subdomain = top_CFC_A_primary
    secondary_boundary = top_cup_bottom
    secondary_subdomain = top_cup_B_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_CFC_top_cup'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_die_bot_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_bot_punch_OD_lm
    secondary_variable = temperature
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = bot_punch_right
    secondary_subdomain = bot_punch_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_die_bot_punch' # closed_thermal_interface_die_bot_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_die_bot_punch]
    type = ModularGapConductanceConstraint
    variable = potential_bot_punch_OD_lm
    secondary_variable = potential
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = bot_punch_right
    secondary_subdomain = bot_punch_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_die_bot_punch' # closed_electric_interface_die_bot_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_die_sample]
    type = ModularGapConductanceConstraint
    variable = temperature_sample_OD_lm
    secondary_variable = temperature
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = sample_right
    secondary_subdomain = sample_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_die_sample' # closed_thermal_interface_die_sample'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_die_sample]
    type = ModularGapConductanceConstraint
    variable = potential_sample_OD_lm
    secondary_variable = potential
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = sample_right
    secondary_subdomain = sample_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_die_sample' # closed_electric_interface_die_sample'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_top_punch_OD_lm
    secondary_variable = temperature
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = top_punch_right
    secondary_subdomain = top_punch_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_die_top_punch' # closed_thermal_interface_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_top_punch_OD_lm
    secondary_variable = potential
    primary_boundary = die_left
    primary_subdomain = die_ID_primary
    secondary_boundary = top_punch_right
    secondary_subdomain = top_punch_OD_secondary
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_die_top_punch' # closed_electric_interface_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []


  [thermal_gap_contact_interface_bot_spacer_die]
    type = ModularGapConductanceConstraint
    variable = temperature_gap_die_bottom_lm
    secondary_variable = temperature
    primary_boundary = bot_spacer_overhang_top
    primary_subdomain = bot_spacer_overhang_top_primary
    secondary_boundary = die_bottom
    secondary_subdomain = gap_die_bottom_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'gap_thermal_interface_bot_spacer_die'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_gap_contact_interface_top_spacer_die]
    type = ModularGapConductanceConstraint
    variable = temperature_gap_die_top_lm
    secondary_variable = temperature
    primary_boundary = top_spacer_overhang_bottom
    primary_subdomain = gap_top_spacer_overhang_bottom_primary
    secondary_boundary = die_top
    secondary_subdomain = gap_die_top_secondary
    gap_geometry_type = PLATE
    gap_flux_models = 'gap_thermal_interface_top_spacer_die'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
[]

[Materials]
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = '        1.82e3           81                            1.303e3                5.88e4                           1.0'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die
             bot_spacer_B_secondary bot_punch_B_secondary
             top_spacer_B_secondary top_cup_B_secondary
             bot_punch_OD_secondary top_punch_OD_secondary'
    # density (kg/m^3), thermal conductivity (W/m-K), and electrical conductivity (S/m) from manufacture datasheet for G535,
    #           available at http://schunk-tokai.pl/pl/wp-content/uploads/Schunk-Tokai-2015-englisch.pdf
    # specific heat capacity for IG110 graphite, https://www.nrc.gov/docs/ML2121/ML21215A346.pdf, equation on pg A-40 at 293K,
  []
    [graphite_em_heating_material]
    type = ElectromagneticHeatingMaterial
    electric_field = potential
    electric_field_heating_name = graphite_electric_field_heating
    electrical_conductivity = graphite_electrical_conductivity
    formulation = 'time'
    solver = 'electrostatic'
    block = 'bot_cup bot_spacer bot_punch
             top_punch top_spacer top_cup die'
  []
  [carbon_fiber_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'CFC_density CFC_thermal_conductivity CFC_heat_capacity CFC_electrical_conductivity CFC_hardness'
    prop_values = ' 1.5e3                 5.0                     1.25e3                   4.0e4                           1.0'
    block = 'bot_CFC top_CFC bot_CFC_B_secondary top_CFC_B_secondary'
    # density (kg/m^3) and electrical conductivity (S/m) from Schunk CF226 manufacturer's datasheet, available at http://schunk-tokai.pl/en/wp-content/uploads/e_CF-226.pdf
    # thermal conductivity (W/m-K), perpendicular to fiber direction, from Schunk CF226 manufacturer's datasheet, available at http://schunk-tokai.pl/en/wp-content/uploads/e_CF-226.pdf
    # specific heat capacity (J/kg-K) from Sommers et al. App. Thermal Engineering 30(11-12) (2010) 1277-1291 for Schunk FU2952
    # hardness set to unity to remove dependence on that quantity
  []
  [CFC_anisotropic_thermal_conductivity]
    type = ADConstantAnisotropicMobility
    tensor = '40 0 0
              0  5 0
              0  0 40'
    M_name = CFC_anisotropic_thermal_conductivity_matrix
    # data sourced from Schunk CF226 manufacturer's datasheet, available at http://schunk-tokai.pl/en/wp-content/uploads/e_CF-226.pdf
  []
    [CFC_em_heating_material]
    type = ElectromagneticHeatingMaterial
    electric_field = potential
    electric_field_heating_name = CFC_electric_field_heating
    electrical_conductivity = CFC_electrical_conductivity
    formulation = 'time'
    solver = 'electrostatic'
    block = 'bot_CFC top_CFC'
  []
  [SS316_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'SS316_density SS316_thermal_conductivity SS316_heat_capacity SS316_electrical_conductivity SS316_hardness'
    prop_values = ' 8e3            16.3                     0.5e3             1.35e6                      1.0'
    # all properties assume fully dense SS316 from MatWeb
    # https://asm.matweb.com/search/specificmaterial.asp?bassnum=mq316a
    # hardness set to unity to remove dependence on that quantity
    block = 'sample sample_B_secondary sample_A_primary
             sample_OD_secondary '
                 # "top_punch_B_secondary_" was previously "powder_top_punch_secondary_subdomain". I think this is incorrect
  []
    [iron_em_heating_material]
    type = ElectromagneticHeatingMaterial
    electric_field = potential
    electric_field_heating_name = SS316_electric_field_heating
    electrical_conductivity = SS316_electrical_conductivity
    formulation = 'time'
    solver = 'electrostatic'
    block = sample
  []
[]

[UserObjects]
  [closed_thermal_interface_bot_cup_bot_CFC]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = CFC_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = CFC_hardness
    boundary = bot_CFC_bottom
  []
  [closed_electric_interface_bot_cup_bot_CFC]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = CFC_electrical_conductivity
    temperature = potential
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = CFC_hardness
    boundary = bot_CFC_bottom
  []
  [closed_thermal_interface_bot_CFC_bot_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = CFC_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_spacer_components_lm
    primary_hardness = CFC_hardness
    secondary_hardness = graphite_hardness
    boundary = bot_spacer_bottom
  []
  [closed_electric_interface_bot_CFC_bot_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = CFC_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_spacer_components_lm
    primary_hardness = CFC_hardness
    secondary_hardness = graphite_hardness
    boundary = bot_spacer_bottom
  []
  [closed_thermal_interface_bot_spacer_bot_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bot_punch_bottom
  []
  [closed_electric_interface_bot_spacer_bot_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bot_punch_bottom
  []
  [closed_thermal_interface_bot_punch_sample]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = SS316_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = SS316_hardness
    boundary = sample_bottom
  []
  [closed_electric_interface_bot_punch_sample]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = SS316_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = SS316_hardness
    boundary = sample_bottom
  []
  [closed_thermal_interface_sample_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = SS316_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = SS316_hardness
    boundary = top_punch_bottom
  []
  [closed_electric_interface_sample_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = SS316_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_components_lm
    primary_hardness = SS316_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_bottom
  []
  [closed_thermal_interface_top_punch_top_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_spacer_bottom
  []
  [closed_electric_interface_top_punch_top_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_punch_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_spacer_bottom
  []
  [closed_thermal_interface_top_spacer_top_CFC]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = CFC_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = CFC_hardness
    boundary = top_CFC_bottom
  []
  [closed_electric_interface_top_spacer_top_CFC]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = CFC_electrical_conductivity
    temperature = potential
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = CFC_hardness
    boundary = top_CFC_bottom
  []
  [closed_thermal_inteface_top_CFC_top_cup]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_cup_bottom
  []
  [closed_electric_interface_top_CFC_top_cup]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_spacer_components_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_cup_bottom
  []

  [thermal_conduction_die_bot_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = bot_punch_right
    gap_conductivity = 5  # W/m-K ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  [electrical_conduction_die_bot_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = bot_punch_right
    gap_conductivity = 6.67e-2  # S/m ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  # [closed_thermal_interface_die_bot_punch]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_thermal_conductivity
  #   secondary_conductivity = graphite_thermal_conductivity
  #   temperature = temperature
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = graphite_hardness
  #   boundary = bot_punch_right
  # []
  # [closed_electric_interface_die_bot_punch]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_electrical_conductivity
  #   secondary_conductivity = graphite_electrical_conductivity
  #   temperature = potential
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = graphite_hardness
  #   boundary = bot_punch_right
  # []
  [thermal_conduction_die_sample]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = sample_right
    gap_conductivity = 5  # W/m-K ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  [electrical_conduction_die_sample]
    type = GapFluxModelConduction
    temperature = potential
    boundary = sample_right
    gap_conductivity = 6.67e-2  # S/m ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  # [closed_thermal_interface_die_sample]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_thermal_conductivity
  #   secondary_conductivity = SS316_thermal_conductivity
  #   temperature = temperature
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = SS316_hardness
  #   boundary = sample_right
  # []
  # [closed_electric_interface_die_sample]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_electrical_conductivity
  #   secondary_conductivity = SS316_electrical_conductivity
  #   temperature = potential
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = SS316_hardness
  #   boundary = sample_right
  # []
  [thermal_conduction_die_top_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = top_punch_right
    gap_conductivity = 5  # W/m-K ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  [electrical_conduction_die_top_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = top_punch_right
    gap_conductivity = 6.67e-2  # S/m ceramaterials, through thickness for graphite foil: https://www.ceramaterials.com/wp-content/uploads/2022/01/GRAPHITE_FOIL_TDS_CM_01_22.pdf
    # use_displaced_mesh = true
  []
  # [closed_thermal_interface_die_top_punch]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_thermal_conductivity
  #   secondary_conductivity = graphite_thermal_conductivity
  #   temperature = temperature
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = graphite_hardness
  #   boundary = top_punch_right
  # []
  # [closed_electric_interface_die_top_punch]
  #   type = GapFluxModelPressureDependentConduction
  #   primary_conductivity = graphite_electrical_conductivity
  #   secondary_conductivity = graphite_electrical_conductivity
  #   temperature = potential
  #   contact_pressure = interface_normal_lm
  #   primary_hardness = graphite_hardness
  #   secondary_hardness = graphite_hardness
  #   boundary = top_punch_right
  # []

  [gap_thermal_interface_bot_spacer_die]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = die_bottom
    gap_conductivity = 0.0306  # W/m-K for argon at 600K: https://www.engineersedge.com/heat_transfer/thermal-conductivity-gases.htm
    # use_displaced_mesh = true
  []
  [gap_thermal_interface_top_spacer_die]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = die_top
    gap_conductivity = 0.0306  # W/m-K for argon at 600K: https://www.engineersedge.com/heat_transfer/thermal-conductivity-gases.htm
    # use_displaced_mesh = true
  []
[]

[Postprocessors]
  [applied_current]
    type = FunctionValuePostprocessor
    function = current_application
  []
  [pyrometer_point_temperature]
    type = PointValue
    variable = temperature
    point = '${fparse sample_radius + 0.004} ${fparse y_pos_bot_punch_sample_interface + sample_height / 2.0} 0'
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

  # mortar contact solver options
  petsc_options = '-snes_converged_reason -pc_svd_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type'
  petsc_options_value = ' lu       superlu_dist'
  snesmf_reuse_base = false

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20
  nl_forced_its = 2
  l_max_its = 50

  dtmax = 10
  dtmin = 1.0e-4
  end_time = 1600 # I am interested in cooling
    [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    optimal_iterations = 10
    iteration_window = 2
    force_step_every_function_point = true
    timestep_limiting_function = current_application
  []
[]

[Outputs]
  color = false
  csv = true
  exodus = true
  perf_graph = true
[]

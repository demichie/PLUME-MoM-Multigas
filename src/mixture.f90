!********************************************************************************
!> \brief Gas/particles mixture module 
!
!> This module contains all the variables and the procedures related to the 
!> gas-particles mixture.
!> \date 28/10/2013
!> @author 
!> Mattia de' Michieli Vitturi
!********************************************************************************

MODULE mixture_module

  USE variables, ONLY: gi , pi_g

  IMPLICIT NONE

  !> gas mass fraction in the mixture
  REAL*8 :: gas_mass_fraction

  !> gas vlume fraction in the mixture
  REAL*8 :: gas_volume_fraction

  !> gas phase density
  REAL*8 :: rho_gas   

  !> universal constant for the mixture
  REAL*8 :: rgasmix  

  !> mixture density
  REAL*8 :: rho_mix  

  !> logical defining if the plume has neutral density at the base
  LOGICAL :: initial_neutral_density

  !> mixture temperature
  REAL*8 :: tp

  !> exit_status
  REAL*8 :: exit_status     

  !> water volume fraction in the mixture
  REAL*8 :: water_volume_fraction

  !> solid volume fraction in the mixture
  REAL*8 :: solid_tot_volume_fraction

  !> initial temperature 
  REAL*8 :: tp0      

  !> initial water volume fraction
  REAL*8 :: water_volume_fraction0

  !> initial water mass fraction
  REAL*8 :: water_mass_fraction0

  !> solid mass fraction in the mixture
  REAL*8 :: solid_tot_mass_fraction

  ! mass flow rate
  REAL*8 :: mass_flow_rate

  !> volcanic gas species number
  INTEGER :: n_gas

  !> volcanic gases densities
  REAL*8, ALLOCATABLE, DIMENSION(:) :: rhovolcgas

  !> gas constants for volcanic gases
  REAL*8, ALLOCATABLE, DIMENSION(:) :: rvolcgas

  !> specific heat capacity for volcanic gases
  REAL*8, ALLOCATABLE, DIMENSION(:) :: cpvolcgas

  !> molecular weight of additional volcanic gases
  REAL*8, ALLOCATABLE, DIMENSION(:) :: volcgas_mol_wt 

  !> initial mass fractions of volcanic gases
  REAL*8, ALLOCATABLE, DIMENSION(:) :: volcgas_mass_fraction0

  !> mass fractions of volcanic gases
  REAL*8, ALLOCATABLE, DIMENSION(:) :: volcgas_mass_fraction

  !> volcanic gases mixture density
  REAL*8 :: rhovolcgas_mix

  !> gas constant of volcanic gases mixture ( J/(kg K) )
  REAL*8 :: rvolcgas_mix

  !> specific heat of volcanic gases mixture
  REAL*8 :: cpvolcgas_mix

  !> mass fraction of the entrained air in the mixture
  REAL*8 :: atm_mass_fraction

  !> mass fraction of the volcanic gas in the mixture
  REAL*8 :: volcgas_mix_mass_fraction

  !> mass fraction of dry air in the mixture
  REAL*8 :: dry_air_mass_fraction

  !> mass fraction of water in the mixture
  REAL*8 :: water_mass_fraction

  !> mass fraction of liquid water in the mixture
  REAL*8 :: liquid_water_mass_fraction

  !> mass fraction of water vapor in the mixture
  REAL*8 :: water_vapor_mass_fraction

  !> mass fraction of ice in the mixture
  REAL*8 :: ice_mass_fraction

  REAL*8 :: volcgas_mix_mol_fract

  REAL*8 :: volcgas_mix_mol_wt

  REAL*8 :: mixture_enthalpy

  !> Density of liquid water in the mixture
  REAL*8 :: rho_lw

  !> Density of ice in the mixture
  REAL*8 :: rho_ice

  REAL*8 :: added_water_temp

  REAL*8 :: added_water_mass_fraction

  SAVE

CONTAINS

  !******************************************************************************
  !> \brief Mixture properties initialization
  !
  !> This subroutine initialize the properties of the gas-particles mixture.
  !
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE initialize_mixture

    ! external variables
    USE meteo_module, ONLY : pa , rho_atm , rair , rwv , c_wv
    USE meteo_module, ONLY : cpair , T_ref , h_wv0 , c_ice, h_lw0 , c_lw ,       &
         da_mol_wt , wv_mol_wt

    USE moments_module, ONLY : n_nodes , n_mom

    USE particles_module, ONLY: n_part , solid_partial_mass_fraction ,          &
         cp_rhop_mom , mom , rhop_mom , distribution , cp_mom

    USE particles_module, ONLY: distribution_variable , cpsolid

    USE plume_module, ONLY: w , r , u , mag_u , phi , log10_mfr, r0

    USE variables, ONLY: verbose_level , write_flag

    ! external procedures
    USE moments_module, ONLY: wheeler_algorithm
    USE particles_module, ONLY: eval_particles_moments 
    USE particles_module, ONLY: particles_density


    IMPLICIT NONE

    REAL*8 :: rho_solid_avg(n_part)

    REAL*8 :: rho_solid_tot_avg

    REAL*8 :: alfa_s(n_part)

    REAL*8 :: atm_volume_fraction 

    REAL*8 :: volcgas_mix_volume_fraction 

    REAL*8, DIMENSION(n_part,n_nodes) :: xi , wi

    INTEGER :: i_part

    INTEGER :: i

    INTEGER :: i_gas

    REAL*8 :: part_dens_array(n_nodes)

    REAL*8 :: Rrhovolcgas_mix

    REAL*8 :: rhowv

    REAL*8 :: enth_at_vent

    REAL*8 :: mixt_enth , check_enth

    REAL*8 :: erupted_mass_Fraction


    IF ( verbose_level .GE. 1 ) WRITE(*,*) 'initialize_mixture'

    !--- Mass fractions in the erutped mixture (before adding external water) ---

    volcgas_mass_fraction(1:n_gas) = volcgas_mass_fraction0(1:n_gas)

    IF ( n_gas .GT. 0 ) THEN

       volcgas_mix_mass_fraction = SUM(volcgas_mass_fraction(1:n_gas))

    ELSE

       volcgas_mix_mass_fraction = 0.D0

    END IF

    water_mass_fraction = water_mass_fraction0

    ! All volcanic water is vapour
    water_vapor_mass_fraction = water_mass_fraction

    ! No air is entrained at the vent             
    dry_air_mass_fraction = 0.D0

    solid_tot_mass_fraction = 1.D0 - water_mass_fraction -                      &
         volcgas_mix_mass_fraction - dry_air_mass_fraction

    !WRITE(*,*) 'solid_tot_mass_fraction',solid_tot_mass_fraction
    !WRITE(*,*) 'water_mass_fraction', water_mass_fraction
    !WRITE(*,*) 'volcgas_mix_mass_fraction', volcgas_mix_mass_fraction
    !WRITE(*,*) 'dry_air_mass_fraction', dry_air_mass_fraction
    !WRITE(*,*) 'water_vapor_mass_fraction', water_vapor_mass_fraction

    DO i_part=1,n_part

       IF ( distribution .EQ. 'constant' ) THEN

          CALL wheeler_algorithm( mom(i_part,0:1), distribution, xi(i_part,:),  &
               wi(i_part,:) )

       ELSE

          CALL wheeler_algorithm( mom(i_part,:) , distribution , xi(i_part,:) , &
               wi(i_part,:) )

       END IF

    END DO

    CALL eval_particles_moments( xi , wi ) 

    IF ( distribution_variable .EQ. "mass_fraction" ) THEN

       cpsolid = ( SUM( solid_partial_mass_fraction(1:n_part) *                 &
            cp_mom(1:n_part,0) ) )                                              &
            / ( SUM( solid_partial_mass_fraction(1:n_part) ) ) 

    END IF

    !Specific enthalpy before addition of external water
    enth_at_vent = solid_tot_mass_fraction * cpsolid * tp0                      & 
         + water_vapor_mass_fraction * ( h_wv0 + c_wv * ( tp0 - T_ref ) )       &
         + volcgas_mix_mass_fraction * cpvolcgas_mix * tp0

    WRITE(*,*) 'Original specific enthalpy at vent =',enth_at_vent

    !------ Corrections of mass fractions and moments for the added water -------
    erupted_mass_fraction = 1.D0 - added_water_mass_fraction

    water_mass_fraction = water_mass_fraction * erupted_mass_fraction +         &
         added_water_mass_fraction

    dry_air_mass_fraction = dry_air_mass_fraction * erupted_mass_fraction

    volcgas_mass_fraction(1:n_gas) = volcgas_mass_fraction(1:n_gas) *           &
         erupted_mass_fraction

    volcgas_mix_mass_fraction = SUM( volcgas_mass_fraction(1:n_gas) )

    gas_mass_fraction = volcgas_mix_mass_fraction + water_vapor_mass_fraction

    solid_tot_mass_fraction = solid_tot_mass_fraction * erupted_mass_fraction

    mom(1:n_part,0:n_mom-1) = mom(1:n_part,0:n_mom-1) * erupted_mass_fraction 

    DO i_part=1,n_part

       IF ( distribution .EQ. 'constant' ) THEN

          CALL wheeler_algorithm( mom(i_part,0:1), distribution, xi(i_part,:),  &
               wi(i_part,:) )

       ELSE

          CALL wheeler_algorithm( mom(i_part,:) , distribution , xi(i_part,:) , &
               wi(i_part,:) )

       END IF

       IF ( verbose_level .GE. 2 ) THEN

          WRITE(*,*) 'i_part',i_part
          WRITE(*,*) 'xi',xi(i_part,:)
          WRITE(*,*) 'wi',wi(i_part,:)

       END IF

       DO i=1,n_nodes

          part_dens_array(i) = particles_density( i_part , xi(i_part,i) )

       END DO

       !WRITE(*,*) 'n_nodes',n_nodes
       !WRITE(*,*) 'part_dens_array',part_dens_array
       !WRITE(*,*) 'wi(i_part,:)',wi(i_part,:)
       !WRITE(*,*) 'SUM( wi(i_part,:)',SUM( wi(i_part,:) )
       !WRITE(*,*) ' mom(i_part,0)', mom(i_part,0)

       IF ( distribution_variable .EQ. 'mass_fraction' ) THEN

          rho_solid_avg(i_part) = 1.D0 / ( SUM( wi(i_part,:) / part_dens_array )&
               / mom(i_part,0) )

       END IF

    END DO

    !WRITE(*,*) 'rho_solid_avg',rho_solid_avg

    rho_solid_tot_avg = 1.D0 / SUM( solid_partial_mass_fraction(1:n_part) /     &
         rho_solid_avg(1:n_part) )

    !WRITE(*,*) 'rho_solid_tot_avg',rho_solid_tot_avg

    DO i_part = 1,n_part

       alfa_s(i_part) = solid_partial_mass_fraction(i_part) *                   &
            rho_solid_tot_avg / rho_solid_avg(i_part)

       IF ( verbose_level .GE. 1 ) THEN

          WRITE(*,*) 'i_part',i_part
          WRITE(*,*) 'rho_solid_avg',rho_solid_avg(i_part)
          WRITE(*,*) 'alfa_s',i_part,alfa_s(i_part)

       END IF

    END DO

    !WRITE(*,*) 'alfa_s',alfa_s

    CALL eval_particles_moments( xi , wi ) 

    !---------- Specific enthalpy after addition of external water --------------
    mixt_enth = erupted_mass_fraction * enth_at_vent +                          &
         added_water_mass_fraction * ( h_lw0+c_lw * ( added_water_temp-T_ref ) )

    ! The new temperature and the partitioning of water is computed
    
     CALL eval_temp(mixt_enth,pa,cpsolid)
      

    ! Compute the specific enthalpy with the new temperature and the corrected
    ! mass fractions
    check_enth = dry_air_mass_fraction * cpair * tp                             &
         + solid_tot_mass_fraction * cpsolid * tp                               & 
         + water_vapor_mass_fraction * ( h_wv0 + c_wv * ( tp - T_ref ) )        &
         + liquid_water_mass_fraction * ( h_lw0 + c_lw * ( tp - T_ref ) )       &
         + ice_mass_fraction * ( c_ice * tp )                                   &
         + volcgas_mix_mass_fraction * cpvolcgas_mix * tp

    gas_mass_fraction = volcgas_mix_mass_fraction + water_vapor_mass_fraction

    IF ( added_water_mass_fraction .GT. 0.D0 ) THEN

       WRITE(*,*) 'WARNING: WATER ADDED AT THE VENT'
       WRITE(*,*) 'New mixture enthalpy =', mixt_enth
       ! WRITE(*,*) 'check_enth', check_enth
       ! WRITE(*,*) 'tp0,tp',tp0,tp
       WRITE(*,*) 'New mixture temperature =',tp
       WRITE(*,*) 'New solid mass fraction =',solid_tot_mass_fraction
       WRITE(*,*) 'New water mass fraction =', water_mass_fraction
       WRITE(*,*) 'New volcgas mix mass fraction =', volcgas_mix_mass_fraction
       ! WRITE(*,*) 'dry_air_mass_fraction', dry_air_mass_fraction
       WRITE(*,*) 'New water vapor mass fraction =', water_vapor_mass_fraction
       WRITE(*,*) 'New liquid water mass fraction =', liquid_water_mass_fraction
       ! WRITE(*,*) 'ice_mass_fraction', ice_mass_fraction
       WRITE(*,*) 'New gas mass fraction =', gas_mass_fraction
       ! WRITE(*,*) 'vent_water',( water_mass_fraction-added_water_mass_fraction ) / &
       !      erupted_mass_fraction
       WRITE(*,*)
       
       
    END IF
       
    !--- With the new temperature compute the densities of the gas components ---

    ! Compute density of gas species and mixture of gas species
    rvolcgas_mix = 0.D0
    cpvolcgas_mix = 0.D0

    IF ( n_gas .GT. 0 ) THEN

       DO i_gas = 1,n_gas

          rvolcgas_mix = rvolcgas_mix + volcgas_mass_fraction(i_gas)               &
               * rvolcgas(i_gas)

          cpvolcgas_mix = cpvolcgas_mix + volcgas_mass_fraction(i_gas)             &
               * cpvolcgas(i_gas)

       END DO

       rvolcgas_mix = rvolcgas_mix / SUM( volcgas_mass_fraction(1:n_gas) )
       cpvolcgas_mix = cpvolcgas_mix / SUM( volcgas_mass_fraction(1:n_gas) )

    ELSE

       rvolcgas_mix = 0.D0
       cpvolcgas_mix = 0.D0

    END IF

    Rrhovolcgas_mix = 0.D0    
    IF ( n_gas .GT. 0 ) THEN

       DO i_gas = 1,n_gas

          Rrhovolcgas_mix = Rrhovolcgas_mix + volcgas_mass_fraction(i_gas)      &
               / (  pa / ( rvolcgas(i_gas) * tp ) )

       END DO

       rhovolcgas_mix =  SUM(volcgas_mass_fraction(1:n_gas)) / Rrhovolcgas_mix

    ELSE

       rhovolcgas_mix =  0.D0

    END IF

    ! Density of water vapour
    rhowv = pa / ( rwv * tp )

    ! Density of gas mixture (water vapur+volcanic gas). No dry air at the vent
    IF ( n_gas .GT. 0 ) THEN 

       rho_gas = gas_mass_fraction / (  water_vapor_mass_fraction / rhowv       &
            + volcgas_mix_mass_fraction / rhovolcgas_mix ) 
    ELSE

       rho_gas = gas_mass_fraction / (  water_vapor_mass_fraction / rhowv)

    END IF

    ! Density of the mixture at the vent
    rho_mix = 1.D0 / ( gas_mass_fraction / rho_gas + solid_tot_mass_fraction /  &
         rho_solid_tot_avg + liquid_water_mass_fraction / rho_lw +              &
         ice_mass_fraction / rho_ice )


    !WRITE(*,*) 'rhowv',rhowv
    !WRITE(*,*) 'rhovolcgas_mix',rhovolcgas_mix
    !WRITE(*,*) 'rho_gas',rho_gas
    !WRITE(*,*) 'rho_ice',rho_ice
    !WRITE(*,*) 'rho_lw',rho_lw
    !WRITE(*,*) 'rho_solid_tot_avg',rho_solid_tot_avg
    !WRITE(*,*) 'rho_mix',rho_mix
    !READ(*,*)

    !--------------- Compute volumetric fractions at the vent ------------------- 
    gas_volume_fraction = gas_mass_fraction * rho_mix / rho_gas

    solid_tot_volume_fraction = solid_tot_mass_fraction * rho_mix /             &
         rho_solid_tot_avg


    !---------- Compute the values of mass flow rate, radius and vent -----------
    !---------- velocity from the input parameters

    IF ( log10_mfr .GT. 0.d0 ) THEN

       mass_flow_rate = 10.0**log10_mfr

       WRITE(*,*) 'Fixed MER [kg/s] =',mass_flow_rate

       IF ( r0 .EQ. -1.D0 ) THEN

          IF ( w .EQ. -1.D0 ) THEN

             ! Equation 4 from Carazzo et al. 2008
             w = 138 * DSQRT( water_mass_fraction0 * 100.d0 )
             mag_u = DSQRT(u*u+w*w)
             phi = ATAN(w/u)

             WRITE(*,*) 'WARNING: calculated initial velocity =',w

          END IF

          r = DSQRT( mass_flow_rate / ( pi_g * rho_mix * mag_u ) )
          r0=r

          IF ( write_flag) WRITE(*,*)                                           &
               'WARNING: Initial radius [m] computed from MER and w0 =',r

       ELSE

          IF ( w .EQ. -1.D0 ) THEN

             r = r0
             w = mass_flow_rate / ( pi_g * rho_mix * r0**2 )
             u = 1.D-5    
             mag_u = DSQRT(u*u+w*w)
             phi = ATAN(w/u)

             WRITE(*,*) 'WARNING: Initial vel [m/s] computed from MER and r =',w

          END IF

       END IF

    ELSE

       mass_flow_rate = pi_g * rho_mix * mag_u * (r**2)
       IF ( write_flag) WRITE(*,'(1x,A,1x,es15.8)')                             &
            'Initial MER [kgs-1] computed from r0 and w0 =',mass_flow_rate

    END IF

    IF ( verbose_level .GE. 1 ) THEN

       WRITE(*,*) 'cpsolid',cpsolid
       WRITE(*,*) 'rho_atm',rho_atm
       WRITE(*,*) 'rho_gas',rho_gas
       WRITE(*,*) 'rho_mix',rho_mix
       WRITE(*,*) 'mass_flow_rate',mass_flow_rate
       WRITE(*,*) 'solid_mass_flow_rates',mass_flow_rate *                      &
            ( 1.D0 - gas_mass_fraction ) * solid_partial_mass_fraction(1:n_part)

       !READ(*,*)

    END IF

    RETURN
  END SUBROUTINE initialize_mixture

  !******************************************************************************
  !> \brief Mixture temperature 
  !
  !> This function evaluates the mixture temperature from the mixture enthalpy.
  !> In addition, the partitioning of water in vapour, liquid and ice is 
  !> computed according to equilibrium conditions.
  !> \param[in]   enth     mixture enthalpy
  !> \param[in]   pa       atmospheric pressure
  !> \param[in]   cpsolid  solid particles specific heat
  !> \date 21/05/2018
  !> @authors 
  !> Federica Pardini, Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE eval_temp(enth,pa,cpsolid)

    USE meteo_module, ONLY : T_ref
    
    USE variables, ONLY : verbose_level , water_flag

    
    IMPLICIT none

    !> mixture enthalpy
    REAL*8, INTENT(IN) :: enth

    !> pressure in Pa
    REAL*8, INTENT(IN) :: pa

    REAL*8, INTENT(IN) :: cpsolid

    
    IF (water_flag) THEN 

        ! --- CASE1: for tp >= T_ref: only water vapour and liquid water --------  

        CALL eval_temp_wv_lw(enth,pa,cpsolid)

        liquid_water_mass_fraction = water_mass_fraction -                      &
             water_vapor_mass_fraction - ice_mass_fraction

        ! --- CASE2: for T_ref - 40 < tp < T_ref: water vapour, liquid water ----
        ! --- and ice ----------------------------------------------------------- 

        SEARCH_TEMP: IF ( ( tp .GT. (T_ref-40) ) .AND. ( tp .LT. T_ref) .AND.   &
             ( liquid_water_mass_fraction .GT. 0.D0 ) ) THEN

            CALL eval_temp_wv_lw_ice(enth,pa,cpsolid)


            ! --- for exit status = 1: no equilibrium between vapour - liquid --- 
            ! --- and ice, skip to CASE 3 (vapour and ice) ----------------------
 
            IF (exit_status .EQ. 1.D0) CALL eval_temp_wv_ice(enth,pa,cpsolid)

        ! --- CASE3: for tp < T_ref - 40: water vapour and ice ------------------
           
        ELSEIF ( tp .LT. (T_ref - 40.D0) ) THEN

            CALL eval_temp_wv_ice(enth,pa,cpsolid)

        END IF SEARCH_TEMP
 
    ELSE
    
        ! --- Evaluate tp for water_flag = false: only water vapour -------------

        CALL eval_temp_no_water(enth,pa,cpsolid)

    END IF

    liquid_water_mass_fraction = water_mass_fraction-water_vapor_mass_fraction  &
         - ice_mass_fraction

    RETURN
    
  END SUBROUTINE eval_temp


  !******************************************************************************
  !> \brief Mixture temperature with vapour and liquid water 
  !
  !> This function evaluates the mixture temperature from the mixture enthalpy, 
  !> when water is present only as vapour and liquid (no ice).
  !> In addition, the partitioning of water in vapour and liquid is computed  
  !> according to equilibrium conditions.
  !> \param[in]   enth     mixture enthalpy
  !> \param[in]   pa       atmospheric pressure
  !> \param[in]   cpsolid  solid particles specific heat
  !> \date 21/05/2018
  !> @authors 
  !> Federica Pardini, Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE eval_temp_wv_lw(enth,pres,cpsolid)

    USE meteo_module, ONLY : cpair , T_ref , h_wv0 , c_wv , c_ice, h_lw0 ,      &
         c_lw , da_mol_wt , wv_mol_wt

    USE variables, ONLY : water_flag 

    ! USE meteo_module

    IMPLICIT none

    !> mixture enthalpy
    REAL*8, INTENT(IN) :: enth

    !> pressure in Pa
    REAL*8, INTENT(IN) :: pres

    REAL*8, INTENT(IN) :: cpsolid

    !> water vapor molar fraction
    REAL*8 :: wv_mol_fract

    !> dry air molar fraction
    REAL*8 :: da_mol_fract

    !> saturation pressure of vapour over liquid (hPa)
    REAL*8 :: el

    !> saturation pressure of vapour over ice (hPa)
    REAL*8 :: es

    REAL*8 :: wv_pres

    REAL*8 :: lw_mf0 , lw_mf1 , lw_mf2

    REAL*8 :: ice_mf0, ice_mf1, ice_mf2

    REAL*8 :: wv_mf0, wv_mf1, wv_mf2

    REAL*8 :: f0, f1, f2

    REAL*8 :: temp0 , temp1 , temp2

    REAL*8 :: enth0 , enth1 , enth2

    !WRITE(*,*) 'water_mass_fraction', water_mass_fraction
    !WRITE(*,*) 'volcgas_mix_mass_fraction', volcgas_mix_mass_fraction
    !WRITE(*,*) 'dry_air_mass_fraction', dry_air_mass_fraction
    !WRITE(*,*) 'water_vapor_mass_fraction', water_vapor_mass_fraction
    !WRITE(*,*) 'liquid_water_mass_fraction', liquid_water_mass_fraction
    !WRITE(*,*) 'ice_mass_fraction', ice_mass_fraction

    !WRITE(*,*)
    !WRITE(*,*) '************** EVAL TEMP **************' 

!!$       IF ( dry_air_mass_fraction .EQ. 0.D0 ) THEN
!!$
!!$          ! --- Vent condition: no dry air is in the mixture --------------------
!!$
!!$          liquid_water_mass_fraction = 0.D0
!!$
!!$          ice_mass_fraction = 0.D0
!!$
!!$          water_vapor_mass_fraction = water_mass_fraction 
!!$
!!$          tp = ( enth - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref )    &
!!$               ) / ( solid_tot_mass_fraction * cpsolid                          &
!!$               + water_vapor_mass_fraction * c_wv                               &
!!$               + volcgas_mix_mass_fraction * cpvolcgas_mix )
!!$
!!$          RETURN
!!$
!!$       END IF


    IF ( n_gas .GT. 0) THEN

       volcgas_mix_mol_wt = SUM( volcgas_mass_fraction(1:n_gas) ) /          &
            SUM( volcgas_mass_fraction(1:n_gas) / volcgas_mol_wt(1:n_gas ) ) 

    ELSE

       volcgas_mix_mol_wt=0

    END IF

    ! --------- All water is liquid and/or vapour ----------------------------

    ice_mass_fraction = 0.D0    


    ! CASE1: all water is liquid       
    lw_mf0 = water_mass_fraction 

    liquid_water_mass_fraction = lw_mf0
    water_vapor_mass_fraction =  water_mass_fraction - liquid_water_mass_fraction &
         - ice_mass_fraction

    volcgas_mix_mol_wt = SUM( volcgas_mass_fraction(1:n_gas) ) /                &
         SUM( volcgas_mass_fraction(1:n_gas) / volcgas_mol_wt(1:n_gas ) ) 

    IF ( n_gas .GT. 0 ) THEN

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /                  &
            ( water_vapor_mass_fraction / wv_mol_wt                                &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                       &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction / volcgas_mix_mol_wt ) / &
            ( water_vapor_mass_fraction / wv_mol_wt                                 &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                        &
            + dry_air_mass_fraction / da_mol_wt )

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                       &
            ( water_vapor_mass_fraction / wv_mol_wt                                 &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                        &
            + dry_air_mass_fraction / da_mol_wt )
    ELSE

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /                  &
            ( water_vapor_mass_fraction / wv_mol_wt                                &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = 0

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                       &
            ( water_vapor_mass_fraction / wv_mol_wt                                 &
            + dry_air_mass_fraction / da_mol_wt )

    END IF

    temp0 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw * T_ref )       &
         - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /             &
         ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction * cpsolid    &
         + liquid_water_mass_fraction * c_lw + water_vapor_mass_fraction * c_wv   &
         +  volcgas_mix_mass_fraction * cpvolcgas_mix + c_ice * ice_mass_fraction )

    IF ( temp0 .GT. 29.65D0 ) THEN

       el = 611.2D0 * DEXP( 17.67D0 * ( temp0 - 273.16D0 ) / ( temp0 - 29.65D0 ) )
       f0 = ( pres - el ) * wv_mol_fract - el * ( da_mol_fract + volcgas_mix_mol_fract )

    ELSE

       el = 0.D0

    END IF

    ! --------- All water is vapor -------------------------------------------

    ! CASE1: all water is vapour (no liquid and ice)      
    lw_mf2 = 0.D0

    liquid_water_mass_fraction = lw_mf2
    water_vapor_mass_fraction = water_mass_fraction - liquid_water_mass_fraction - ice_mass_fraction

    IF ( n_gas .GT. 0) THEN

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction /                    &
            volcgas_mix_mol_wt ) / ( water_vapor_mass_fraction / wv_mol_wt      &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

    ELSE

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = 0.d0

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

    END IF

    temp2 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw * T_ref )      &
         - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /             &
         ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction * cpsolid    &
         + liquid_water_mass_fraction * c_lw + water_vapor_mass_fraction * c_wv &
         +  volcgas_mix_mass_fraction * cpvolcgas_mix  + c_ice * ice_mass_fraction )

    IF ( temp2 .GT. 29.65D0 ) THEN

       el = 611.2D0 * DEXP( 17.67D0 * ( temp2 - 273.16D0 ) / ( temp2 - 29.65D0 ) )
       f2 = ( pres - el ) * wv_mol_fract - el * da_mol_fract - el * volcgas_mix_mol_fract

    ELSE

       el = 0.D0

    END IF


    ! --------- Options: all vapour, all liquid, vapour+liquid ---------------
    temp1 = 0.D0

    vapour_liquid_case:IF ( ( f0 .LT. 0.D0 ) .AND. ( f2 .LT. 0.D0 ) ) THEN

       ! ---------  All water is vapour -------------------------------------
       liquid_water_mass_fraction = 0.D0

       water_vapor_mass_fraction = water_mass_fraction -                    &
            liquid_water_mass_fraction - ice_mass_fraction

       tp = temp2

       wv_pres = wv_mol_fract * pres

       ! WRITE(*,*) 'all vapour, tp:',tp

       IF ( tp .GT. T_ref ) RETURN

    ELSEIF ( ( f0 .GT. 0.D0 ) .AND. ( f2 .GT. 0.D0 ) ) THEN

       ! --------- All water is liquid --------------------------------------
       liquid_water_mass_fraction = water_mass_fraction

       water_vapor_mass_fraction = water_mass_fraction -                    &
            liquid_water_mass_fraction 

       tp = temp0

       WRITE(*,*) 'all liquid, tp:',tp

       IF ( tp .GT. T_ref ) RETURN

    ELSE

       find_temp1:DO

          ! ---------- Water is vapour+liquid ------------------------------
          lw_mf1 = 0.5D0 * ( lw_mf0 + lw_mf2 )

          liquid_water_mass_fraction = lw_mf1
          water_vapor_mass_fraction = water_mass_fraction -                 &
               liquid_water_mass_fraction - ice_mass_fraction

          IF ( n_gas .GT. 0 ) THEN

             wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /    &
                  ( water_vapor_mass_fraction / wv_mol_wt                  &
                  + volcgas_mix_mass_fraction / volcgas_mix_mol_wt         &
                  + dry_air_mass_fraction / da_mol_wt )

             volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction /         &
                  volcgas_mix_mol_wt ) / ( water_vapor_mass_fraction /     &
                  wv_mol_wt + volcgas_mix_mass_fraction /                  &
                  volcgas_mix_mol_wt + dry_air_mass_fraction / da_mol_wt )

             da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /        &
                  ( water_vapor_mass_fraction / wv_mol_wt                  &
                  + volcgas_mix_mass_fraction / volcgas_mix_mol_wt         &
                  + dry_air_mass_fraction / da_mol_wt )

          ELSE

             wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /        &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + dry_air_mass_fraction / da_mol_wt )

             volcgas_mix_mol_fract = 0

             da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /            &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + dry_air_mass_fraction / da_mol_wt )            

          END IF


          temp1 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw*T_ref )  &
               - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /       &
               ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction *      &
               cpsolid + liquid_water_mass_fraction * c_lw +                    &
               water_vapor_mass_fraction * c_wv +  volcgas_mix_mass_fraction *  &
               cpvolcgas_mix + c_ice * ice_mass_fraction )

          IF ( temp1 .GT. 29.65D0 ) THEN

             el = 611.2D0 * DEXP( 17.67D0 * ( temp1 - 273.16D0 ) / ( temp1 - 29.65D0 ) )
             f1 = ( pres - el ) * wv_mol_fract - el * da_mol_fract - el *         &
                  volcgas_mix_mol_fract

          END IF

          IF (  f1 * f0 .LT. 0.D0 ) THEN

             lw_mf2 = lw_mf1
             f2 = f1
             temp2 = temp1

          ELSE

             lw_mf0 = lw_mf1
             f0 = f1
             temp0 = temp1

          END IF

          IF ( DABS(temp2-temp0) .LT. 1.D-5 ) THEN

             tp = temp1

             water_vapor_mass_fraction = water_mass_fraction - lw_mf1

             EXIT find_temp1

          ELSEIF ( DABS(lw_mf2 - lw_mf0) .LT. 1.D-7 ) THEN

             tp = temp1

             water_vapor_mass_fraction = water_mass_fraction - lw_mf1

             EXIT find_temp1

          END IF

       END DO find_temp1

    END IF vapour_liquid_case

  END SUBROUTINE eval_temp_wv_lw




  SUBROUTINE eval_temp_wv_lw_ice(enth,pres,cpsolid)

    USE meteo_module, ONLY : cpair , T_ref , h_wv0 , c_wv , c_ice, h_lw0 , c_lw ,       &
         da_mol_wt , wv_mol_wt

    USE variables, ONLY : water_flag 

    ! USE meteo_module

    IMPLICIT none

    !> mixture enthalpy
    REAL*8, INTENT(IN) :: enth

    !> pressure in Pa
    REAL*8, INTENT(IN) :: pres

    REAL*8, INTENT(IN) :: cpsolid

    !> water vapor molar fraction
    REAL*8 :: wv_mol_fract

    !> dry air molar fraction
    REAL*8 :: da_mol_fract

    !> saturation pressure of vapour over liquid (hPa)
    REAL*8 :: el

    !> saturation pressure of vapour over ice (hPa)
    REAL*8 :: es

    REAL*8 :: wv_pres

    REAL*8 :: lw_mf0 , lw_mf1 , lw_mf2

    REAL*8 :: ice_mf0, ice_mf1, ice_mf2

    REAL*8 :: wv_mf0, wv_mf1, wv_mf2

    REAL*8 :: f0, f1, f2

    REAL*8 :: temp0 , temp1 , temp2

    REAL*8 :: enth0 , enth1 , enth2

    exit_status = 0.D0

    !REAL*8 :: exit_status


    !SEARCH_LW_ICE_WV:IF ( ( tp .GT. T_ref-40 ) .AND. ( liquid_water_mass_fraction .GT. 0.D0 ) ) THEN

    ! ------ Water can be liquid, vapour and ice -----------------------------
    ! For (T_ref-40) <= T <= T_ref, liquid water mass fraction varies linearly
    ! between 0 and equilibrium value at t=T_ref (if positive)

    ! CASE 0: only ice and water vapour at t=T_ref-40
    temp0 = T_ref - 40.D0


    es = -9.097D0 * ( (273.16D0 / temp0 ) - 1.D0 ) - 3.566D0 * log10(273.16D0 / temp0) &
         + 0.876D0 * ( 1.D0 - (temp0 / 273.16D0))

    es = 611.22D0 * ( 10.D0**es ) 

    wv_mol_fract = es / pres 

    IF ( n_gas .GT. 0 ) THEN

       wv_mf0 = - ( (dry_air_mass_fraction / da_mol_wt + volcgas_mix_mass_fraction / volcgas_mix_mol_wt) * &
            
            wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

    ELSE

       wv_mf0 = - ( (dry_air_mass_fraction / da_mol_wt) * &
            
            wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

    END IF

    lw_mf0 = 0.D0

    ice_mf0 = water_mass_fraction - wv_mf0

    enth0 = dry_air_mass_fraction * cpair * temp0                       &
         + solid_tot_mass_fraction * cpsolid * temp0                               & 
         + wv_mf0 * ( h_wv0 + c_wv * ( temp0 - T_ref ) )        &
         + lw_mf0 * ( h_lw0 + c_lw * ( temp0 - T_ref ) )       &
         + ice_mf0 * ( c_ice * temp0 )       &
         + volcgas_mix_mass_fraction * cpvolcgas_mix * temp0

    f0 = enth - enth0

    !WRITE(*,*) 'CASE0'
    !WRITE(*,*) 'lw_mf0,ice_mf0,wv_mf0',lw_mf0,ice_mf0,wv_mf0

    ! CASE 0: only liquid and water vapour at t=T_ref       
    temp2 = T_ref

    el = 611.2D0 * DEXP( 17.67D0 * ( temp2 - 273.16D0 ) / ( temp2 - 29.65D0 ) )

    wv_mol_fract = el / pres 

    IF ( n_gas .GT. 0 ) THEN

       wv_mf2 = - ( (dry_air_mass_fraction / da_mol_wt + volcgas_mix_mass_fraction / volcgas_mix_mol_wt) * &
            
            wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

    ELSE

       wv_mf2 = - ( (dry_air_mass_fraction / da_mol_wt) * &
            
            wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

    END IF

    lw_mf2 = water_mass_fraction - wv_mf2
    ice_mf2 = 0.D0

    !WRITE(*,*) 'CASE2'
    !WRITE(*,*) 'wv_mol_fract',wv_mol_fract
    !WRITE(*,*) 'pres',pres
    !WRITE(*,*) 'lw_mf2,ice_mf2,wv_mf2',lw_mf2,ice_mf2,wv_mf2
    !READ(*,*)

    enth2 = dry_air_mass_fraction * cpair * temp2                       &
         + solid_tot_mass_fraction * cpsolid * temp2                               & 
         + wv_mf2 * ( h_wv0 + c_wv * ( temp2 - T_ref ) )        &
         + lw_mf2 * ( h_lw0 + c_lw * ( temp2 - T_ref ) )       &
         + ice_mf2 * ( c_ice * temp2 )       &
         + volcgas_mix_mass_fraction * cpvolcgas_mix * temp2

    f2 = enth - enth2


    !WRITE(*,*) 'f0,f2',f0,f2
    !READ(*,*)
    
    
    IF ((f0*f2 .GT. 0.D0)) THEN
    
        exit_status = 1.0

        RETURN

    END IF 


    IF ( ( lw_mf2 .GT. 0.D0 ) .AND. (lw_mf2 .LT. 1.D0 ) ) THEN

       ! --- We enter here if there is liquid water at t=Tref, otherwise
       ! --- there are only ice and water vapour

       find_temp:DO
          ! search for (T_ref-40) <= T <= T_ref and for mass fractions giving
          ! the correct enthalpy

          temp1 = (temp0 + temp2) * 0.5D0

          lw_mf1 = lw_mf2 * ( temp1 - ( T_ref - 40) ) / 40.D0 

          es = -9.097D0 * ( (273.16D0 / temp1 ) - 1.D0 ) - 3.566D0 * log10(273.16D0 / temp1) &
               + 0.876D0 * ( 1.D0 - (temp1 / 273.16D0))

          es = 611.22D0 * ( 10.D0**es ) 

          wv_mol_fract = es / pres 

          IF ( n_gas .GT. 0 ) THEN

             wv_mf1 = - ( (dry_air_mass_fraction / da_mol_wt + volcgas_mix_mass_fraction / volcgas_mix_mol_wt) * &
                  
                  wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

          ELSE

             wv_mf1 = - ( (dry_air_mass_fraction / da_mol_wt) * &
                  
                  wv_mol_wt * wv_mol_fract ) / (wv_mol_fract - 1.D0)

          END IF

          ice_mf1 = water_mass_fraction - wv_mf1 - lw_mf1

          enth1 = dry_air_mass_fraction * cpair * temp1                       &
               + solid_tot_mass_fraction * cpsolid * temp1                               & 
               + wv_mf1 * ( h_wv0 + c_wv * ( temp1 - T_ref ) )        &
               + lw_mf1 * ( h_lw0 + c_lw * ( temp1 - T_ref ) )       &
               + ice_mf1 * ( c_ice * temp1 )       &
               + volcgas_mix_mass_fraction * cpvolcgas_mix * temp1

          f1 = enth - enth1

          !WRITE(*,*) 'f0,f1,f2',f0,f1,f2
         ! WRITE(*,*) 'temp0,temp1,temp2',temp0,temp1,temp2


          !WRITE(*,*) 'lw_mf1,ice_mf1,wv_mf1',lw_mf1,ice_mf1,wv_mf1


          IF (f1 * f0 .LT. 0.D0) THEN

             temp2 = temp1
             f2 = f1

          ELSE

             temp0 = temp1
             f0 = f1

          END IF


          IF (ABS(temp2-temp0) .LT. 1.0D-5) THEN

             IF ( ( wv_mf1 .LT. 0.D0 ) .OR. ( ice_mf1 .LT. 0.D0 ))THEN

                WRITE(*,*) 'WARNING: negative mass fraction'
                WRITE(*,*) 'water_vapor_mass_fraction =', wv_mf1
                WRITE(*,*) 'ice_mass_fraction =', ice_mf1
                WRITE(*,*) 'liquid_mass_fraction =', ice_mf1
                READ(*,*)

             END IF


             water_vapor_mass_fraction = wv_mf1
             ice_mass_fraction = ice_mf1
             liquid_water_mass_fraction = lw_mf1
             tp = temp1

             !WRITE(*,*) 'CHECK: tp <= 273.15',' tp:',tp


             RETURN

          END IF

       END DO find_temp


    ELSEIF (lw_mf2 .LT. 0.D0) THEN

        exit_status = 1.D0

        RETURN

    END IF

  END SUBROUTINE eval_temp_wv_lw_ice



  SUBROUTINE eval_temp_wv_ice(enth,pres,cpsolid)

    USE meteo_module, ONLY : cpair , T_ref , h_wv0 , c_wv , c_ice, h_lw0 , c_lw ,       &
         da_mol_wt , wv_mol_wt

    USE variables, ONLY : water_flag 

    ! USE meteo_module

    IMPLICIT none

    !> mixture enthalpy
    REAL*8, INTENT(IN) :: enth

    !> pressure in Pa
    REAL*8, INTENT(IN) :: pres

    REAL*8, INTENT(IN) :: cpsolid

    !> water vapor molar fraction
    REAL*8 :: wv_mol_fract

    !> dry air molar fraction
    REAL*8 :: da_mol_fract

    !> saturation pressure of vapour over liquid (hPa)
    REAL*8 :: el

    !> saturation pressure of vapour over ice (hPa)
    REAL*8 :: es

    REAL*8 :: wv_pres

    REAL*8 :: lw_mf0 , lw_mf1 , lw_mf2

    REAL*8 :: ice_mf0, ice_mf1, ice_mf2

    REAL*8 :: wv_mf0, wv_mf1, wv_mf2

    REAL*8 :: f0, f1, f2

    REAL*8 :: temp0 , temp1 , temp2

    REAL*8 :: enth0 , enth1 , enth2






    ! ------- All water is vapour and/or ice ----------------------------------

    !WRITE(*,*) '! ---- CHECK ice/vapour'


    liquid_water_mass_fraction = 0.D0


    ice_mf0 = 0.D0  

    ice_mass_fraction = ice_mf0

    water_vapor_mass_fraction = water_mass_fraction - ice_mass_fraction &
         - liquid_water_mass_fraction

    !WRITE(*,*) '--->water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) '--->liquid_water_mass_fraction',liquid_water_mass_fraction
    !WRITE(*,*) '--->ice_mass_fraction',ice_mass_fraction
    !WRITE(*,*) '--->volcgas_mix_mass_fraction', volcgas_mix_mass_fraction
    !WRITE(*,*) '--->volcgas_mix_mol_wt',volcgas_mix_mol_wt
    !WRITE(*,*) '--->water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) '--->wv_mol_wt ', wv_mol_wt 
    !WRITE(*,*) '--->volcgas_mix_mol_wt',volcgas_mix_mol_wt    
    !WRITE(*,*) '--->dry_air_mass_fraction',dry_air_mass_fraction

    IF ( n_gas .GT. 0) THEN

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction /                    &
            volcgas_mix_mol_wt ) / ( water_vapor_mass_fraction / wv_mol_wt      &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

    ELSE

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = 0.d0

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

    END IF

    temp0 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw * T_ref )      &
         - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /             &
         ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction * cpsolid    &
         + liquid_water_mass_fraction * c_lw + water_vapor_mass_fraction * c_wv &
         +  volcgas_mix_mass_fraction * cpvolcgas_mix  + c_ice * ice_mass_fraction )

    !WRITE(*,*) 'water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) 'wv_mol_fract',wv_mol_fract
    !WRITE(*,*) 'da_mol_fract',da_mol_fract
    !WRITE(*,*) 'volcgas_mix_mol_fract',volcgas_mix_mol_fract
    !READ(*,*)

    IF ( temp0 .GT. 29.65D0 ) THEN

       es = -9.097D0 * ( (273.16D0 / temp0 ) - 1.D0 ) - 3.566D0 * log10(273.16D0 / temp0) &
            + 0.876D0 * ( 1.D0 - (temp0 / 273.16D0))

       es = 611.22D0 * ( 10.D0**es )

       f0 = ( pres - es ) * wv_mol_fract - es * da_mol_fract - es * volcgas_mix_mol_fract

    END IF


    ! WRITE(*,*) '! ---- All water is ice'

    ice_mf2 = water_mass_fraction 

    ice_mass_fraction = ice_mf2

    water_vapor_mass_fraction = water_mass_fraction - ice_mass_fraction &
         - liquid_water_mass_fraction

    !WRITE(*,*) '--->water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) '--->liquid_water_mass_fraction',liquid_water_mass_fraction
    !WRITE(*,*) '--->ice_mass_fraction',ice_mass_fraction
    !WRITE(*,*) '--->volcgas_mix_mass_fraction', volcgas_mix_mass_fraction
    !WRITE(*,*) '--->volcgas_mix_mol_wt',volcgas_mix_mol_wt
    !WRITE(*,*) '--->water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) '--->wv_mol_wt ', wv_mol_wt 
    !WRITE(*,*) '--->volcgas_mix_mol_wt',volcgas_mix_mol_wt    
    !WRITE(*,*) '--->dry_air_mass_fraction',dry_air_mass_fraction

    IF ( n_gas .GT. 0) THEN

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction /                    &
            volcgas_mix_mol_wt ) / ( water_vapor_mass_fraction / wv_mol_wt      &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + volcgas_mix_mass_fraction / volcgas_mix_mol_wt                    &
            + dry_air_mass_fraction / da_mol_wt )

    ELSE

       wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /               &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

       volcgas_mix_mol_fract = 0.d0

       da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /                   &
            ( water_vapor_mass_fraction / wv_mol_wt                             &
            + dry_air_mass_fraction / da_mol_wt )

    END IF

    temp2 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw * T_ref )      &
         - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /             &
         ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction * cpsolid    &
         + liquid_water_mass_fraction * c_lw + water_vapor_mass_fraction * c_wv &
         +  volcgas_mix_mass_fraction * cpvolcgas_mix  + c_ice * ice_mass_fraction )

    !WRITE(*,*) 'water_vapor_mass_fraction',water_vapor_mass_fraction
    !WRITE(*,*) 'wv_mol_fract',wv_mol_fract
    !WRITE(*,*) 'da_mol_fract',da_mol_fract
    !WRITE(*,*) 'volcgas_mix_mol_fract',volcgas_mix_mol_fract

    IF ( temp2 .GT. 29.65D0 ) THEN

       es = -9.097D0 * ( (273.16D0 / temp2) - 1.D0 ) - 3.566D0 * log10(273.16D0 / temp2) &
            + 0.876D0 * ( 1.D0 - (temp2 / 273.16D0))

       es = 611.22D0 * ( 10.D0**es )

       f2 = ( pres - es ) * wv_mol_fract - es * da_mol_fract - es * volcgas_mix_mol_fract

    END IF

    !WRITE(*,*) 'all vapour, tp:',temp0
    !WRITE(*,*) 'all ice, tp:',temp2


    IF ( ( f0 .LT. 0.D0 ) .AND. ( f2 .LT. 0.D0 ) ) THEN !All water is vapour

       ice_mass_fraction = 0.D0
       water_vapor_mass_fraction = water_mass_fraction - liquid_water_mass_fraction - ice_mass_fraction

       tp = temp0

       !WRITE(*,*) 'all vapour, tp:',tp
       !WRITE(*,*) '*****'
       !READ(*,*)
       RETURN

    ELSEIF ( ( f0 .GT. 0.D0 ) .AND. ( f2 .GT. 0.D0 ) ) THEN !All water is ice

       ice_mass_fraction = water_mass_fraction
       water_vapor_mass_fraction = water_mass_fraction - liquid_water_mass_fraction - ice_mass_fraction

       tp = temp2
       !WRITE(*,*) 'all ice, tp:',tp
       !WRITE(*,*) '*****'
       !READ(*,*)
       RETURN

    ELSE !All water is vapour and/or ice

       find_temp2:DO  

          ice_mf1 = 0.5D0 * ( ice_mf0 + ice_mf2 )

          ice_mass_fraction = ice_mf1

          !WRITE(*,*) ' ice_mass_fraction ', ice_mass_fraction

          water_vapor_mass_fraction = water_mass_fraction - ice_mass_fraction &
               - liquid_water_mass_fraction

          !WRITE(*,*) ' water_vapor_mass_fraction ', water_vapor_mass_fraction

          IF ( n_gas .GT. 0) THEN

             wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /        &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + volcgas_mix_mass_fraction / volcgas_mix_mol_wt             &
                  + dry_air_mass_fraction / da_mol_wt )

             volcgas_mix_mol_fract = ( volcgas_mix_mass_fraction /             &
                  volcgas_mix_mol_wt ) / ( water_vapor_mass_fraction /         &
                  wv_mol_wt + volcgas_mix_mass_fraction / volcgas_mix_mol_wt   &
                  + dry_air_mass_fraction / da_mol_wt )

             da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /            &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + volcgas_mix_mass_fraction / volcgas_mix_mol_wt             &
                  + dry_air_mass_fraction / da_mol_wt )


          ELSE

             wv_mol_fract = ( water_vapor_mass_fraction / wv_mol_wt ) /        &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + dry_air_mass_fraction / da_mol_wt )

             volcgas_mix_mol_fract = 0

             da_mol_fract = ( dry_air_mass_fraction / da_mol_wt ) /            &
                  ( water_vapor_mass_fraction / wv_mol_wt                      &
                  + dry_air_mass_fraction / da_mol_wt )            

          END IF

          !WRITE(*,*) 'water_vapor_mass_fraction',water_vapor_mass_fraction
          !WRITE(*,*) 'wv_mol_fract',wv_mol_fract
          !WRITE(*,*) 'da_mol_fract',da_mol_fract
          !WRITE(*,*) 'volcgas_mix_mol_fract',volcgas_mix_mol_fract


          temp1 = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw*T_ref )  &
               - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /       &
               ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction *      &
               cpsolid + liquid_water_mass_fraction * c_lw +                    &
               water_vapor_mass_fraction * c_wv +  volcgas_mix_mass_fraction *  &
               cpvolcgas_mix + c_ice * ice_mass_fraction )

          es = -9.097D0 * ( 273.16D0 / temp1 -1.D0 ) - 3.566D0 * log10(273.16D0 / temp1) &
               + 0.876D0 * (1.D0 - (temp1 / 273.16D0))

          es = 611.22D0 * (10.0D0**es)

          f1 = ( pres - es ) * wv_mol_fract - es * da_mol_fract - es * volcgas_mix_mol_fract



          !WRITE(*,*) 'volcgas_mix_mol_fract ',volcgas_mix_mol_fract
          !WRITE(*,*) wv_mol_fract+volcgas_mix_mol_fract+da_mol_fract

          !WRITE(*,*) 't0,t1,t2',temp0,temp1,temp2
          !WRITE(*,*) 'lw_mf0,lw_mf1,lw_mf2',lw_mf0,lw_mf1,lw_mf2
          !WRITE(*,*) 'f0,f1,f2',f0,f1,f2
          !READ(*,*)

          IF (  f1 * f2 .LT. 0.D0 ) THEN

             ice_mf0 = ice_mf1
             f0 = f1
             temp0 = temp1

          ELSE

             ice_mf2 = ice_mf1
             f2 = f1
             temp2 = temp1

          END IF

          IF ( DABS(temp2-temp0) .LT. 1.D-3 ) THEN

             tp = temp1

             ice_mass_fraction = ice_mf1
             water_vapor_mass_fraction = water_mass_fraction - ice_mass_fraction &
                  - liquid_water_mass_fraction


             ! WRITE(*,*)'tp 1',tp
             EXIT find_temp2

          ELSEIF ( DABS(ice_mf2 - ice_mf0) .LT. 1.D-7 ) THEN

             tp = temp1

             ! WRITE(*,*)'tp 2',tp

             ice_mass_fraction = ice_mf1
             water_vapor_mass_fraction = water_mass_fraction - ice_mass_fraction &
                  - liquid_water_mass_fraction

             EXIT find_temp2

          END IF

       END DO find_temp2

    END IF

  END SUBROUTINE eval_temp_wv_ice



  SUBROUTINE eval_temp_no_water(enth,pres,cpsolid)

    USE meteo_module, ONLY : cpair , T_ref , h_wv0 , c_wv , c_ice, h_lw0 , c_lw ,       &
         da_mol_wt , wv_mol_wt


    ! USE meteo_module

    IMPLICIT none

    !> mixture enthalpy
    REAL*8, INTENT(IN) :: enth

    !> pressure in Pa
    REAL*8, INTENT(IN) :: pres

    REAL*8, INTENT(IN) :: cpsolid

    liquid_water_mass_fraction = 0.D0

    ice_mass_fraction = 0.D0

    water_vapor_mass_fraction = water_mass_fraction 



          tp = ( enth - liquid_water_mass_fraction * ( h_lw0 - c_lw * T_ref )       &
             - water_vapor_mass_fraction * ( h_wv0 - c_wv * T_ref ) ) /             &
              ( dry_air_mass_fraction * cpair + solid_tot_mass_fraction * cpsolid    &
            + liquid_water_mass_fraction * c_lw + water_vapor_mass_fraction * c_wv   &
            +  volcgas_mix_mass_fraction * cpvolcgas_mix + c_ice * ice_mass_fraction )


  !WRITE(*,*) 'tp ',tp
  !READ(*,*)
  END SUBROUTINE eval_temp_no_water




END MODULE mixture_module




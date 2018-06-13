!********************************************************************************
!> \brief Particles module
!
!> This module contains the procedures and the variables related to the solid
!> particles. In particular, the statistical moments of the properties of the 
!> particles are defined and evaluated in this module.
!> \date 22/10/2013
!> @author 
!> Mattia de' Michieli Vitturi
!********************************************************************************
MODULE particles_module
  !
  USE moments_module, ONLY : n_mom , n_nodes

  USE variables, ONLY : aggregation_flag , verbose_level , indent_space , FMT

  IMPLICIT NONE

  INTEGER :: n_part

  INTEGER :: n_part_org

  !> mass fraction of the particle phases with respect to the total solid
  REAL*8, ALLOCATABLE, DIMENSION(:) :: solid_partial_mass_fraction

  !> volume fraction of the particle phases with respect to the total solid
  REAL*8, ALLOCATABLE, DIMENSION(:) :: solid_partial_volume_fraction

  !> mass fraction of the particle phases with respect to the mixture
  REAL*8, ALLOCATABLE, DIMENSION(:) :: solid_mass_fraction

  !> volume fraction of the particle phases with respect to the mixture
  REAL*8, ALLOCATABLE, DIMENSION(:) :: solid_volume_fraction

  !> Moments of the particles diameter
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: mom

  !> Moments of the settling velocities
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: set_mom

  !> Moments of the densities
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: rhop_mom

  !> Moments of the densities times the settling velocities
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: set_rhop_mom

  !> Moments of the heat capacities 
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: cp_mom 

  !> Moments of the heat capacities times the densities
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: cp_rhop_mom 

  !> Moments of the settling velocities times the heat cap times the densities
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: set_cp_rhop_mom

  !> Moments of the settling velocities times the heat capacity
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: set_cp_mom

  !> Term accounting for the birth of aggregates in the moments equations
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: birth_mom

  !> Term accounting for the loss of particles because of aggregation 
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: death_mom

  !> shape factor for settling velocity (Pfeiffer)
  REAL*8 :: shape_factor

  !> First diameter for the density function
  REAL*8, ALLOCATABLE :: diam1(:)

  !> Density at d=diam1
  REAL*8, ALLOCATABLE :: rho1(:)

  !> Second diameter for the density function
  REAL*8, ALLOCATABLE :: diam2(:)

  !> Density at d=diam1
  REAL*8, ALLOCATABLE :: rho2(:)

  REAL*8, ALLOCATABLE :: cp_part(:)

  REAL*8 :: cpsolid

  !> Initial (at the base) moments of the particles diameter
  REAL*8, DIMENSION(1:50,0:100) :: mom0

  !> Settling model:\n
  !> - 'textor'    => Textor et al. 2006
  !> - 'pfeiffer'  => Pfeiffer et al. 2005
  !> .
  CHARACTER*10 :: settling_model

  !> Ditribution of the particles:\n
  !> - 'beta'      => beta distribution
  !> - 'lognormal' => lognormal distribution
  !> - 'constant'  => 
  !> .
  CHARACTER(LEN=20) :: distribution

  CHARACTER(LEN=20) :: distribution_variable

  !> Flag for the aggregation:\n
  !> - 'TRUE'   => aggregation enabled
  !> - 'FALSE'  => aggregation disabled
  LOGICAL, ALLOCATABLE :: aggregation_array(:)

  !> Array for porosity volume fraction of aggregates
  REAL*8, ALLOCATABLE :: aggregate_porosity(:)
  
  !> Aggregation kernel model:\n
  !> - 'constant'   => beta=1
  !> - 'brownian'
  !> - 'sum'
  !> .
  CHARACTER(LEN=20) :: aggregation_model

  !> Index defining the couple aggregated-non aggregated
  INTEGER, ALLOCATABLE :: aggr_idx(:)

  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: xi_part
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: w_part
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: part_dens_array
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: part_set_vel_array
  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: part_cp_array

  REAL*8, ALLOCATABLE, DIMENSION(:,:,:,:) :: part_beta_array 

  REAL*8 :: t_part


  SAVE

CONTAINS

  !******************************************************************************
  !> \brief Particles variables inizialization
  !
  !> This subroutine allocate and evaluate the variables defining the moments for  
  !> the particles. The moments are then corrected, if needed, and then the 
  !> abscissas and weights for the quadrature formulas are computed.
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE allocate_particles

    IMPLICIT NONE

    ALLOCATE ( solid_partial_mass_fraction(1:n_part) )
    ALLOCATE ( solid_partial_volume_fraction(1:n_part) )
    ALLOCATE ( solid_mass_fraction(1:n_part) )
    ALLOCATE ( solid_volume_fraction(1:n_part) )

    ! Allocation of the arrays for the moments
    ALLOCATE ( mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( set_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( rhop_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( set_rhop_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( set_cp_rhop_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( set_cp_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( cp_rhop_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( cp_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( birth_mom(1:n_part,0:n_mom-1) )
    ALLOCATE ( death_mom(1:n_part,0:n_mom-1) )

    ! Allocation of the parameters for the variable density
    ALLOCATE ( diam1(n_part) )
    ALLOCATE ( rho1(n_part) )
    ALLOCATE ( diam2(n_part) )
    ALLOCATE ( rho2(n_part) )

    ALLOCATE ( cp_part(n_part) )

    !Allocation of arrays for quadrature variables
    ALLOCATE ( xi_part(n_part,n_nodes) )
    ALLOCATE ( w_part(n_part,n_nodes) )

    
    ! Allocation of arrays for aggregation
    ALLOCATE ( aggregation_array(n_part) )
    ALLOCATE ( aggregate_porosity(n_part) )
    ALLOCATE ( aggr_idx(n_part) )

    ALLOCATE ( part_dens_array(n_part,n_nodes) )
    ALLOCATE ( part_set_vel_array(n_part,n_nodes) )
    ALLOCATE ( part_cp_array(n_part,n_nodes) )
    ALLOCATE ( part_beta_array(n_part,n_part,n_nodes,n_nodes) )


  END SUBROUTINE allocate_particles

  SUBROUTINE deallocate_particles

    IMPLICIT NONE

    DEALLOCATE ( solid_partial_mass_fraction )
    DEALLOCATE ( solid_partial_volume_fraction )
    DEALLOCATE ( solid_mass_fraction )
    DEALLOCATE ( solid_volume_fraction )

    ! Allocation of the arrays for the moments
    DEALLOCATE ( mom )
    DEALLOCATE ( set_mom )
    DEALLOCATE ( rhop_mom )
    DEALLOCATE ( set_rhop_mom )
    DEALLOCATE ( set_cp_rhop_mom )
    DEALLOCATE ( set_cp_mom )
    DEALLOCATE ( cp_rhop_mom )
    DEALLOCATE ( cp_mom )
    DEALLOCATE ( birth_mom )
    DEALLOCATE ( death_mom )

    ! Allocation of the parameters for the variable density
    DEALLOCATE ( diam1 )
    DEALLOCATE ( rho1 )
    DEALLOCATE ( diam2 )
    DEALLOCATE ( rho2 )

    DEALLOCATE ( cp_part )

    DEALLOCATE ( xi_part )
    DEALLOCATE ( w_part )
    
    ! Allocation of arrays for aggregation
    DEALLOCATE ( aggregation_array )
    DEALLOCATE ( aggregate_porosity )
    DEALLOCATE ( aggr_idx )

    DEALLOCATE ( part_dens_array )
    DEALLOCATE ( part_set_vel_array )
    DEALLOCATE ( part_cp_array )
    DEALLOCATE ( part_beta_array )


  END SUBROUTINE deallocate_particles


  !******************************************************************************
  !> \brief Particles variables inizialization
  !
  !> This subroutine allocate and evaluate the variables defining the moments for  
  !> the particles. The moments are then corrected, if needed, and then the 
  !> abscissas and weights for the quadrature formulas are computed.
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE initialize_particles

    USE moments_module, ONLY : wheeler_algorithm , moments_correction
    USE variables, ONLY : verbose_level

    IMPLICIT NONE

    REAL*8, DIMENSION(n_part,n_nodes) :: xi
    REAL*8, DIMENSION(n_part,n_nodes) :: w

    INTEGER :: i_part

    DO i_part=1,n_part

       mom(i_part,:) = mom0(i_part,0:n_mom-1)

       ! CALL moments_correction(mom(i_part,:),iter)

       CALL wheeler_algorithm( mom(i_part,0:n_mom-1) , distribution ,           &
            xi(i_part,:) , w(i_part,:) )

       IF ( verbose_level .GE. 1 ) THEN

          WRITE(*,*) 'part ',i_part
          WRITE(*,*) 'mom',mom(i_part,:)
          WRITE(*,*) 'abscissas',xi(i_part,:)
          WRITE(*,*) 'weights',w(i_part,:)
          READ(*,*)

       END IF


    END DO

    CALL eval_particles_moments( xi(1:n_part,:) , w(1:n_part,:) ) 


  END SUBROUTINE initialize_particles


  !******************************************************************************
  !> \brief Settling velocity
  !
  !> This function evaluates the settling velocity of a particle given the size
  !> (diameter), using the expression given in Textor et al. 2006 or in Pfeiffer 
  !> et al 2005, accordingly with the variable SETTLING MODEL specified in the
  !> input file.
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   diam_in  particle diameter (m or phi)
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION particles_settling_velocity(i_part,diam_in)
    !
    USE meteo_module, ONLY : rho_atm , rho_atm0 , visc_atm

    USE variables, ONLY : gi , pi_g , verbose_level

    IMPLICIT NONE

    REAL*8 :: particles_settling_velocity

    INTEGER, INTENT(IN) :: i_part
    REAL*8, INTENT(IN) :: diam_in

    REAL*8 :: diam

    REAL*8 :: rhop

    REAL*8 :: k1 , k2 , k3
    REAL*8 :: CD , CD1 , CD2

    REAL*8 :: Reynolds , Reynoldsk1k2
    REAL*8 :: Vinit , Vg_Ganser

    INTEGER :: i

    !> cross sectional area
    REAL*8 :: A_cs

    !> Drag coefficients at Rey=100,1000
    REAL*8 :: Cd_100 , Cd_1000

    !> Drag coefficent for intermediate values of Re
    REAL*8 :: Cd_interp

    !> Settling velocity at Rey=100,1000
    REAL*8 :: Us_100 , Us_1000

    !> Mass of the particle
    REAL*8 :: mass

    !> Settling velocities
    REAL*8 :: Us , Us_1 ,Us_2

    !> Reynolds numbers for the two solutions of the settling equation
    REAL*8 :: Rey1 , Rey2

    !> Coefficients of the settling equation
    REAL*8 :: c0 , c1 , c2

    !> Square root of the discriminant of the settling equation
    REAL*8 :: sqrt_delta

    IF ( distribution_variable .EQ. 'mass_fraction' ) THEN

       diam = 1.D-3 * 2.D0 ** ( - diam_in )

    ELSE

       diam = diam_in

    END IF

    rhop = particles_density(i_part,diam_in)

    IF ( settling_model .EQ. 'textor' ) THEN

       ! Textor et al. 2006

       IF ( diam .LE. 1.D-4 ) THEN

          k1 = 1.19D5   ! (m^2 kg^-1 s^-1 )

          particles_settling_velocity = k1 * rhop * DSQRT( rho_atm0 / rho_atm ) &
               * ( 0.5D0 * diam )**2

       ELSEIF ( diam .LE. 1.D-3 ) THEN

          k2 = 8.D0    ! (m^3 kg^-1 s^-1 )

          particles_settling_velocity = k2 * rhop * DSQRT( rho_atm0 / rho_atm ) &
               * ( 0.5D0 * diam )

       ELSE 

          k3 = 4.833D0 ! (m^2 kg^-0.5 s^-1 )
          CD = 0.75D0

          particles_settling_velocity = k3 * DSQRT( rhop / CD )                 &
               * DSQRT(  rho_atm0 / rho_atm ) * DSQRT( 0.5D0 * diam )

       END IF

    ELSEIF ( settling_model .EQ. 'ganser' ) THEN 

       Vinit = diam**2 * gi * ( rhop - rho_atm ) / (18.D0*visc_atm)

       DO i=1,10

          IF (i.EQ.1) REYNOLDS = rho_atm * Vinit * diam / visc_atm

          K1 = 3.0/(1.0+2.0*(shape_factor**(-0.5)))

          K2 = 10.0**(1.8148*((-1.0*log10(shape_factor))**0.5743))

          REYNOLDSK1K2 = REYNOLDS * K1 * K2

          CD1 = K2 * 24.0 / REYNOLDSK1K2  *                                     &
               ( 1.D0 + 0.1118 * REYNOLDSK1K2**0.6567 )

          CD2 = 0.4305 * K2 / ( 1.0 + 3305.0 / REYNOLDSK1K2 )

          CD = CD1 + CD2

          VG_GANSER = ( ( 4.0 * gi * diam * ( rhop - rho_atm ) )                &
               / ( 3.D0 * CD * rho_atm) )**0.5

          REYNOLDS = rho_atm * VG_GANSER * diam / visc_atm

       ENDDO

       particles_settling_velocity = Vg_Ganser

       IF ( Vg_Ganser .LE. 0.D0 ) THEN

          WRITE(*,*) 'NEGATIVE VALUE', Vinit,Vg_Ganser

       END IF


    ELSEIF ( settling_model .EQ. 'pfeiffer' ) THEN

       k1 = shape_factor**(-0.828)
       k2 = 2.D0 * DSQRT( 1.07 - shape_factor )

       mass = rhop * 4.D0/3.D0 * pi_g * ( 0.5*diam )**3

       A_cs = pi_g * ( 0.5*diam )**2

       c0 = -2.D0 * diam * mass * gi
       c1 = 24.D0 * visc_atm * k1 * A_cs
       c2 = rho_atm * diam * k2 * A_cs

       sqrt_delta = sqrt( c1**2 - 4 * c0*c2 )

       Us_1 = ( - c1 + sqrt_delta ) / ( 2 * c2 )
       Us_2 = ( - c1 - sqrt_delta ) / ( 2 * c2 )


       Cd_100 = 24.D0/100.D0 * k1 + k2
       Us_100 = sqrt( 2 * mass * gi / ( Cd_100*rho_atm * A_cs ) )

       Cd_1000 = 1.D0
       Us_1000 = sqrt( 2 * mass * gi / ( Cd_1000*rho_atm * A_cs ) )

       Rey1 = rho_atm * diam * Us_1 / visc_atm
       Rey2 = rho_atm * diam * Us_2 / visc_atm

       IF ( verbose_level .GE. 4 ) THEN

          WRITE(*,*) 'rho_atm , diam , Us_1 , visc_atm',rho_atm , diam , Us_1 , &
               visc_atm
          WRITE(*,*) 'Rey1,Rey2',Rey1,Rey2
          READ(*,*)

       END IF

       ! Initialization only
       Us = Us_1000

       IF ( ( Rey1 .GT. 0.D0 ) .AND. ( Rey1 .LE. 100.D0 ) ) THEN

          ! For small Reynolds numbers the drag coefficient is given by Eq.8
          ! of Pfeiffer et al. 2005 and the settling velocity is Us_1

          Us = Us_1  

       ELSEIF ( ( Rey1 .GT. 100.D0 ) .AND. ( Rey1 .LE. 1000.D0 ) ) THEN

          ! For intermediate Reyonlds numbers, 100<Re<1000, the drag coefficient 
          ! is linearly interpolated between Cd_100 and Cd_1000

          Cd_interp = Cd_100 + ( Rey1 - 100 ) / ( 1000 - 100 ) *                &
               ( Cd_1000 - Cd_100)
          Us = sqrt( 2 * mass * gi / ( Cd_interp * rho_atm * A_cs ) )

       ELSEIF ( Rey1 .GT. 1000.D0 ) THEN

          ! For large Reynolds numbers the drag coefficient is taken as Cd=1,
          ! as in Pfeiffer et al. 2005 with the settling velocity is Us_1000

          Us = Us_1000

       END IF

       IF ( ( Rey2 .GT. 0.D0 ) .AND. ( Rey2 .LE. 100.D0 ) ) THEN 

          Us = Us_2

       ELSEIF ( ( Rey2 .GT. 100.D0 ) .AND. ( Rey2 .LE. 1000.D0 ) ) THEN 

          Cd_interp = Cd_100 + ( Rey2 - 100 ) / ( 1000 - 100 )                  &
               * ( Cd_1000 - Cd_100)

          Us = DSQRT( 2.D0 * mass * gi / ( Cd_interp * rho_atm * A_cs ) )

       ELSEIF ( Rey2 .GT. 1000.D0 ) THEN

          Us = Us_1000

       END IF

       particles_settling_velocity = Us

    ELSE

       WRITE(*,*) 'wrong settling model'
       STOP

    END IF

  END FUNCTION particles_settling_velocity

  !******************************************************************************
  !> \brief Heat capacity
  !
  !> This function evaluates the heat capacity of the particles given the size
  !> (diameter). 
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   diam_in  particle diameter (m or phi)
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION particles_heat_capacity(i_part,diam_in)
    !
    IMPLICIT NONE

    REAL*8 :: particles_heat_capacity
    INTEGER, INTENT(IN) :: i_part
    REAL*8, INTENT(IN) :: diam_in
    REAL*8 :: diam

    IF ( distribution_variable .EQ. 'mass_fraction' ) THEN

       diam = 1.D-3 * 2.D0 ** ( - diam_in )

    ELSE

       diam = diam_in

    END IF

    particles_heat_capacity = cp_part(i_part)

  END FUNCTION particles_heat_capacity

  !******************************************************************************
  !> \brief Particle density
  !
  !> This function evaluates the density of a particle given the size (diameter),
  !> using the expression given in Bonadonna and Phillips, 2003.
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   diam_in  particle diameter (m or phi)
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION particles_density(i_part,diam_in)
    !
    IMPLICIT NONE

    REAL*8 :: particles_density

    INTEGER, INTENT(IN) :: i_part
    REAL*8, INTENT(IN) :: diam_in

    REAL*8 :: diam

    REAL*8 :: diam_phi , diam1_phi , diam2_phi


    IF ( distribution_variable .EQ. 'mass_fraction' ) THEN

       diam = 1.D-3 * 2.D0 ** ( - diam_in )

    ELSE

       diam = diam_in

    END IF

    IF ( diam .LE. diam1(i_part) ) THEN

       particles_density = rho1(i_part)

    ELSEIF ( diam .LE. diam2(i_part) ) THEN

       diam_phi = -log(diam*1000)/log(2.D0)
       diam1_phi = -log(diam1(i_part)*1000)/log(2.D0)
       diam2_phi = -log(diam2(i_part)*1000)/log(2.D0)

       particles_density = rho1(i_part) + ( diam_phi - diam1_phi ) /            &
            ( diam2_phi - diam1_phi ) * ( rho2(i_part) - rho1(i_part) )

    ELSE

       particles_density = rho2(i_part)

    END IF

    ! WRITE(*,*) 'i_part,diam_in',i_part,diam_in
    ! WRITE(*,*) 'rho1(i_part),rho2(i_part)',rho1(i_part),rho2(i_part)
    ! WRITE(*,*) 'diam,particles_density',diam,particles_density

    RETURN

  END FUNCTION particles_density

  !******************************************************************************
  !> \brief Brownian aggregation
  !
  !> This function evaluates the aggregation kernel using a Brownian formulation
  !> given in Marchisio et al., 2003.
  !> \param[in]   i_part   particle family index 
  !> \param[in]   j_part   particle family index 
  !> \param[in]   diam_i   first particle diameter (m or phi)
  !> \param[in]   diam_j   second particle diameter (m or phi) 
  !> \date 05/05/2015
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION particles_beta(i_part,j_part,diam_i,diam_j,lw_mf,ice_mf)
    !
    IMPLICIT NONE

    REAL*8 :: particles_beta

    INTEGER, INTENT(IN) :: i_part
    INTEGER, INTENT(IN) :: j_part
    REAL*8, INTENT(IN) :: diam_i
    REAL*8, INTENT(IN) :: diam_j
    REAL*8, INTENT(IN) :: lw_mf 
    REAL*8, INTENT(IN) :: ice_mf 



    !aggregation_model = 'CONSTANT'
    !aggregation_model = 'COSTA'

    SELECT CASE ( aggregation_model )

    CASE DEFAULT

       particles_beta = 0.D0

    CASE ( 'CONSTANT' )

       particles_beta = 1.D-10

    CASE ( 'BROWNIAN' )

       particles_beta = ( diam_i + diam_j ) ** 2 / ( diam_i + diam_j ) 

    CASE ( 'SUM' )

       particles_beta =  diam_i**3 + diam_j**3

    CASE ( 'COSTA')

       particles_beta = aggregation_kernel(i_part,j_part,diam_i,diam_j,lw_mf,   &
            ice_mf)

    END SELECT

    IF ( verbose_level .GE. 2 ) THEN

       WRITE(*,*) 'beta =',particles_beta
       WRITE(*,*) 

       WRITE(*,FMT) ' ','END particles_beta'
       indent_space = indent_space - 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"

    END IF

    RETURN

  END FUNCTION particles_beta


  !******************************************************************************
  !> \brief Aggregation kernel 
  !
  !> This function evaluates the aggregation kernel, using the expression given 
  !> in Textor et al. 2006.
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   j_part   particle phase index 
  !> \param[in]   diam_i   particle diameter (m)
  !> \param[in]   diam_j   particle diameter (m)
  !> \date 24/01/2014
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION aggregation_kernel(i_part,j_part,diam_i,diam_j,lw_mf,ice_mf)

    IMPLICIT NONE

    REAL*8 :: aggregation_kernel

    INTEGER, INTENT(IN) :: i_part
    INTEGER, INTENT(IN) :: j_part
    REAL*8, INTENT(IN) :: diam_i
    REAL*8, INTENT(IN) :: diam_j
    REAL*8, INTENT(IN) :: lw_mf 
    REAL*8, INTENT(IN) :: ice_mf 

    REAL*8 :: beta
    REAL*8 :: alfa

    IF ( verbose_level .GE. 2 ) THEN

       indent_space = indent_space + 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"
       WRITE(*,FMT) ' ','BEGINNING aggregation_kernel'
       READ(*,*)

    END IF

    beta = collision_kernel(i_part,j_part,diam_i,diam_j)

    alfa = coalescence_efficiency(i_part,j_part,diam_i,diam_j,lw_mf,ice_mf)

    aggregation_kernel = beta * alfa

    !WRITE(*,*) 'aggregation_kernel, beta, alfa',aggregation_kernel, beta, alfa
    !READ(*,*)

    IF ( verbose_level .GE. 2 ) THEN

       WRITE(*,FMT) ' ','END aggregation_kernel'
       indent_space = indent_space - 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"

    END IF

    RETURN

  END FUNCTION aggregation_kernel

  !******************************************************************************
  !> \brief Collision kernel 
  !
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   j_part   particle phase index 
  !> \param[in]   diam_i   particle diameter (m)
  !> \param[in]   diam_j   particle diameter (m)
  !> \date 24/01/2014
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION collision_kernel(i_part,j_part,diam_i,diam_j)

    USE meteo_module, ONLY : visc_atm

    USE variables, ONLY: pi_g

    IMPLICIT NONE

    REAL*8 :: collision_kernel

    INTEGER, INTENT(IN) :: i_part
    INTEGER, INTENT(IN) :: j_part
    REAL*8,INTENT(IN) :: diam_i
    REAL*8,INTENT(IN) :: diam_j

    !> Brownian motion collisions kernel
    REAL*8 :: beta_B   

    !> Laminar and turbulent fluid shear collisions kernel
    REAL*8 :: beta_S

    !> Differential sedimentation kernel
    REAL*8 :: beta_DS

    !> Boltzmann constant
    REAL*8 :: k_b

    !> Partciles settling velocities
    REAL*8 :: Vs_i , Vs_j

    !> Gravitational collision efficiency
    REAL*8 :: E_coll

    !> Rate of dissipation of turbulent kinetic energy
    REAL*8 :: epsilon

    !> Fluid shear
    REAL*8 :: Gamma_s

    !> Air kinematic viscosity
    REAL*8 :: air_kin_viscosity


    IF ( verbose_level .GE. 2 ) THEN

       indent_space = indent_space + 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"
       WRITE(*,FMT) ' ','BEGINNING collision_kernel'
       READ(*,*)

    END IF


    k_b =1.3806488D-23 

    visc_atm = 1.98D-5

    ! Eq. 3, first term Costa et al. JGR 2010
    beta_B = 2.D0 / 3.D0 * k_b * t_part / visc_atm * ( diam_i + diam_j )**2     &
         / ( diam_i*diam_j ) 

    ! Gamma_s = DSQRT( 1.3D0 * epsilon * air_kin_viscosity )

    ! Value from Table 1 (Costa 2010)
    Gamma_s = 0.0045D0 

    ! Eq. 3, second term Costa et al. JGR 2010
    beta_S = 1.D0 / 6.D0 * Gamma_s * ( diam_i + diam_j )**3

    Vs_i = particles_settling_velocity(i_part,diam_i)

    Vs_j = particles_settling_velocity(j_part,diam_j)

    ! Eq. 3, third term Costa et al. JGR 2010
    beta_DS = pi_g / 4.D0 * ( diam_i + diam_j )**2 * ABS( Vs_j - Vs_i )

    collision_kernel = beta_B + beta_S + beta_DS

    IF ( verbose_level .GE. 2 ) THEN

       WRITE(*,FMT) ' ','END collision_kernel'
       indent_space = indent_space - 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"

    END IF

    RETURN

  END FUNCTION collision_kernel

  !******************************************************************************
  !> \brief Collision efficiency 
  !
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   j_part   particle phase index 
  !> \param[in]   diam_i   particle diameter (m)
  !> \param[in]   diam_j   particle diameter (m)
  !> \date 24/01/2014
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION collision_efficiency(i_part,j_part,diam_i,diam_j)

    USE variables, ONLY : gi

    IMPLICIT NONE

    REAL*8 :: collision_efficiency

    INTEGER, INTENT(IN) :: i_part
    INTEGER, INTENT(IN) :: j_part

    REAL*8, INTENT(IN) :: diam_i
    REAL*8, INTENT(IN) :: diam_j

    REAL*8 :: E_V , E_A

    REAL*8 :: Re

    REAL*8 :: Stokes

    REAL*8 :: kin_visc_air

    !> Partciles settling velocities
    REAL*8 :: Vs_i , Vs_j

    IF ( verbose_level .GE. 2 ) THEN

       indent_space = indent_space + 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"
       WRITE(*,FMT) ' ','BEGINNING collision_efficiency'

    END IF


    ! Settling velocities
    Vs_i = particles_settling_velocity(i_part,diam_i)
    Vs_j = particles_settling_velocity(j_part,diam_j)


    IF ( diam_i .GT. diam_j ) THEN

       Re = diam_i * Vs_i / kin_visc_air

       Stokes = 2.D0 * Vs_j * ABS( Vs_i - Vs_j ) / diam_i * gi

    ELSE

       Re = diam_j * Vs_j / kin_visc_air 

       Stokes = 2.D0 * Vs_i * ABS( Vs_j - Vs_i ) / diam_j * gi

    END IF

    IF ( Stokes > 1.214 ) THEN

       E_V = ( 1.D0 + ( 0.75 * LOG( 2.D0 * Stokes ) / ( Stokes - 1.214 ) ) )** &
            ( -2.D0 )

    ELSE

       E_V = 0.D0

    END IF

    collision_efficiency = ( 60.D0 * E_V + E_A * Re ) / ( 60.D0 * Re )

    IF ( verbose_level .GE. 2 ) THEN

       WRITE(*,FMT) ' ','END collision_efficiency'
       indent_space = indent_space - 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"

    END IF

    RETURN

  END FUNCTION collision_efficiency


  !******************************************************************************
  !> \brief Coalescence efficiency 
  !
  !> \param[in]   i_part   particle phase index 
  !> \param[in]   j_part   particle phase index 
  !> \param[in]   diam_i   particle diameter (m)
  !> \param[in]   diam_j   particle diameter (m)
  !> \date 24/01/2014
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  FUNCTION coalescence_efficiency(i_part,j_part,diam_i,diam_j,lw_mf,ice_mf)

    USE variables, ONLY: gi

    IMPLICIT NONE

    REAL*8 :: coalescence_efficiency

    INTEGER, INTENT(IN) :: i_part
    INTEGER, INTENT(IN) :: j_part

    REAL*8, INTENT(IN) :: diam_i
    REAL*8, INTENT(IN) :: diam_j
    REAL*8, INTENT(IN) :: lw_mf 
    REAL*8, INTENT(IN) :: ice_mf 
    
    REAL*8 :: coalescence_efficiency_ice , coalescence_efficiency_water
    
    !> particle Stokes number
    REAL*8 :: Stokes

    !> Critical Stokes number
    REAL*8 :: Stokes_cr

    !> Efficiency exponent
    REAL*8 :: q

    !> Partciles settling velocities
    REAL*8 :: Vs_i , Vs_j

    REAL*8 :: rho_i , rho_j

    REAL*8 :: mu_liq

    IF ( verbose_level .GE. 2 ) THEN

       indent_space = indent_space + 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"
       WRITE(*,FMT) ' ','BEGINNING coalescence_efficiency'

    END IF

    ! Eq. 5 Costa et al. JGR 2010
    coalescence_efficiency_ice = 0.09D0
    
    Vs_i = particles_settling_velocity(i_part,diam_i)
    Vs_j = particles_settling_velocity(j_part,diam_j)
    
    rho_i = particles_density(i_part,diam_i)
    rho_j = particles_density(j_part,diam_j)
    
    
    mu_liq = 5.43D-4
    
    ! Eq. 6 Costa et al. JGR 2010 (CHECK DENSITY!)
    Stokes = 8.d0 * 0.5D0 * ( rho_i + rho_j ) / ( 9.d0 * mu_liq )               &
         * diam_i * diam_j / ( diam_i + diam_j )
    
    Stokes_cr = 1.3D0
    
    q = 0.8D0
    
    ! Eq. 8 Costa et al. JGR 2010
    coalescence_efficiency_water = 1.D0 / ( 1.D0 + ( Stokes / Stokes_cr ) ) ** q 

    IF ( lw_mf .GT. 0.D0 ) THEN

       IF ( ice_mf .GT. 0.D0 ) THEN

          coalescence_efficiency = ( lw_mf * coalescence_efficiency_water       &
               + ice_mf * coalescence_efficiency_ice ) / ( lw_mf + ice_mf )

       ELSE
       
          coalescence_efficiency = coalescence_efficiency_water

       END IF
          
    ELSEIF ( ice_mf .GT. 0.D0 ) THEN

       coalescence_efficiency = coalescence_efficiency_ice
          
    ELSE

       coalescence_efficiency = 0.D0

    END IF
          
    
    IF ( verbose_level .GE. 2 ) THEN

       WRITE(*,FMT) ' ','END coalescence_efficiency'
       indent_space = indent_space - 2
       WRITE(FMT,*) indent_space
       FMT = "(A" // TRIM(FMT) // ",A)"

    END IF

    RETURN

  END FUNCTION coalescence_efficiency


  !******************************************************************************
  !> \brief Particles moments computation
  !
  !> This subroutine compute the moments of the particles properties (density,
  !> heat capacity and settling velocity) using the quadrature formulas.
  !> \param[in]   xi     abscissas for the quadrature
  !> \param[out]  w      weights for the quadrature
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE eval_particles_moments( xi , w )

    ! external variables
    USE variables, ONLY : verbose_level
    USE variables, ONLY : pi_g

    ! external procedures
    USE meteo_module, ONLY : zmet

    IMPLICIT NONE

    REAL*8, DIMENSION(n_part,n_nodes), INTENT(IN) :: xi
    REAL*8, DIMENSION(n_part,n_nodes), INTENT(IN) :: w


    INTEGER :: j_node , j1_node , j2_node

    INTEGER :: i , j , j1 , j2
    INTEGER :: i_part , j_part

    INTEGER :: i_mom
    
    REAL*8 :: diam_i_j1 , diam_i_j2
    REAL*8 :: diam_j_j1 , diam_j_j2

    CALL zmet

    DO i_part=1,n_part

       DO j=1,n_nodes

          part_dens_array(i_part,j) = particles_density( i_part , xi(i_part,j) )

          part_set_vel_array(i_part,j) = particles_settling_velocity( i_part ,  &
               xi(i_part,j) ) 

          part_cp_array(i_part,j) = particles_heat_capacity( i_part,xi(i_part,j))  

       END DO

       IF ( verbose_level .GE. 2 ) THEN

          WRITE(*,*) 'i_part',i_part
          WRITE(*,*) 'abscissas', xi(i_part,1:n_nodes)
          WRITE(*,*) 'weights', w(i_part,1:n_nodes)
          WRITE(*,*) 'part_dens_array',part_dens_array(i_part,:)
          WRITE(*,*) 'part_set_vel_array',part_set_vel_array(i_part,:)
          WRITE(*,*) 'part_cp_array',part_cp_array(i_part,:)

       END IF

    END DO

    DO i_part=1,n_part

       DO i=0,n_mom-1

          set_mom(i_part,i) = SUM( part_set_vel_array(i_part,:) * w(i_part,:)   &
               * xi(i_part,:)**i ) / mom(i_part,i)

          rhop_mom(i_part,i) = SUM( part_dens_array(i_part,:) * w(i_part,:)     &
               * xi(i_part,:)**i ) / mom(i_part,i)

          cp_mom(i_part,i) = SUM( part_cp_array(i_part,:) * w(i_part,:)         &
               * xi(i_part,:)**i ) / mom(i_part,i) 

          cp_rhop_mom(i_part,i) = SUM( part_cp_array(i_part,:)                  &
               * part_dens_array(i_part,:) * w(i_part,:) * xi(i_part,:)**i )    &
               / mom(i_part,i) 

          set_rhop_mom(i_part,i) = SUM( part_set_vel_array(i_part,:)            &
               *  part_dens_array(i_part,:) * w(i_part,:) * xi(i_part,:)**i )   &
               / mom(i_part,i) 

          set_cp_rhop_mom(i_part,i) = SUM( part_set_vel_array(i_part,:)         &
               * part_cp_array(i_part,:) * part_dens_array(i_part,:) *          &
               w(i_part,:) * xi(i_part,:)**i ) / mom(i_part,i) 

          set_cp_mom(i_part,i) = SUM( part_set_vel_array(i_part,:)              &
               * part_cp_array(i_part,:) * w(i_part,:) * xi(i_part,:)**i )      &
               / mom(i_part,i) 

          IF ( aggregation_flag ) THEN


          END IF

          IF ( verbose_level .GE. 2 ) THEN

             WRITE(*,*) 'i_part,i_mom',i_part,i
             WRITE(*,*) 'abscissas', xi(i_part,1:n_nodes)
             WRITE(*,*) 'set_mom(i_part,i_mom) = ',set_mom(i_part,i)

          END IF

       END DO

    END DO


    RETURN

  END SUBROUTINE eval_particles_moments

  !******************************************************************************
  !> \brief Particles moments computation
  !
  !> This subroutine compute the moments of the particles properties (density,
  !> heat capacity and settling velocity) using the quadrature formulas.
  !> \param[in]   xi     abscissas for the quadrature
  !> \param[out]  w      weights for the quadrature
  !> \date 22/10/2013
  !> @author 
  !> Mattia de' Michieli Vitturi
  !******************************************************************************

  SUBROUTINE eval_aggregation_moments( xi , w , lw_mf , ice_mf )

    ! external variables
    USE variables, ONLY : verbose_level
    USE variables, ONLY : pi_g

    ! external procedures
    USE meteo_module, ONLY : zmet

    IMPLICIT NONE

    REAL*8, DIMENSION(n_part,n_nodes), INTENT(IN) :: xi
    REAL*8, DIMENSION(n_part,n_nodes), INTENT(IN) :: w
    REAL*8, INTENT(IN) :: lw_mf
    REAL*8, INTENT(IN) :: ice_mf

    INTEGER :: j_node , j1_node , j2_node

    INTEGER :: i , j , j1 , j2
    INTEGER :: i_part , j_part

    INTEGER :: i_mom
    
    REAL*8 :: diam_i_j1 , diam_i_j2
    REAL*8 :: diam_j_j1 , diam_j_j2

    CALL zmet

    DO i_part=1,n_part

       DO j=1,n_nodes

          part_dens_array(i_part,j) = particles_density( i_part , xi(i_part,j) )

       END DO

       IF ( verbose_level .GE. 2 ) THEN

          WRITE(*,*) 'i_part',i_part
          WRITE(*,*) 'abscissas', xi(i_part,1:n_nodes)
          WRITE(*,*) 'weights', w(i_part,1:n_nodes)
          WRITE(*,*) 'part_dens_array',part_dens_array(i_part,:)

       END IF

    END DO


    DO i_part=1,n_part_org

       DO j1_node=1,n_nodes

          IF ( aggregation_array(i_part) ) THEN

             j_part = aggr_idx(i_part)

             DO j2_node=1,n_nodes

                diam_i_j1 =  1.D-3 * 2.D0 ** ( -xi(i_part,j1_node) )
                diam_i_j2 =  1.D-3 * 2.D0 ** ( -xi(i_part,j2_node) )
                diam_j_j1 =  1.D-3 * 2.D0 ** ( -xi(j_part,j1_node) )
                diam_j_j2 =  1.D-3 * 2.D0 ** ( -xi(j_part,j2_node) )

                part_beta_array(i_part,i_part,j1_node,j2_node) = particles_beta( &
                     i_part , i_part , diam_i_j1 , diam_i_j2 , lw_mf , ice_mf )

                part_beta_array(i_part,j_part,j1_node,j2_node) = particles_beta( &
                     i_part , j_part , diam_i_j1 , diam_j_j2 , lw_mf , ice_mf )

                part_beta_array(j_part,i_part,j1_node,j2_node) = particles_beta( &
                     j_part , i_part , diam_j_j1 , diam_i_j2 , lw_mf , ice_mf )

                part_beta_array(j_part,j_part,j1_node,j2_node) = particles_beta( &
                     j_part , j_part , diam_j_j1 , diam_j_j2 , lw_mf , ice_mf )

             END DO

          END IF

       END DO

    END DO


    DO i_part=1,n_part

       IF ( ( aggregation_array(i_part) ) .AND. ( i_part .LE. n_part_org) ) THEN

          ! index of the aggregates family for the family i_part
          j_part = aggr_idx(i_part)

          ! WRITE(*,*) 'particles',i_part,j_part

          mom_loop:DO i_mom=0,n_mom-1

             ! total birth rate moments for the i_part family (original - org)
             birth_mom(i_part,i_mom) = 0.D0
             ! total death rate moments for the i_part family (original - org)
             death_mom(i_part,i_mom) = 0.D0

             ! total birth rate moments for the j_part family (nonOrg)
             birth_mom(j_part,i_mom) = 0.D0
             ! total death rate moments for the j_part family (nonOrg)
             death_mom(j_part,i_mom) = 0.D0

             DO j1=1,n_nodes

                DO j2=1,n_nodes

                   diam_i_j1 = 1.D-3 * 2.D0 ** ( - xi(i_part,j1) )
                   diam_i_j2 = 1.D-3 * 2.D0 ** ( - xi(i_part,j2) )
                   diam_j_j1 = 1.D-3 * 2.D0 ** ( - xi(j_part,j1) )
                   diam_j_j2 = 1.D-3 * 2.D0 ** ( - xi(j_part,j2) )

                   ! death of org due to org-org aggregation
                   death_mom(i_part,i_mom) = death_mom(i_part,i_mom)            &
                        + w(i_part,j1) * w(i_part,j2) * xi(i_part,j1)**i_mom    &
                        * part_beta_array(i_part,i_part,j1,j2) * 6.D0           &
                        / ( pi_g * diam_i_j2**3 * part_dens_array(i_part,j2) )

                   !WRITE(*,*) i_part,j_part,j1,j2
                   !WRITE(*,*) w(i_part,j1) , w(i_part,j2) , w(j_part,j2) ,      &
                   !     xi(i_part,j1)**i_mom
                   !WRITE(*,*) part_beta_array(i_part,i_part,j1,j2),             &
                   !     death_mom(i_part,i_mom),diam_i_j1**3

                   ! death of org due to org-nonOrg aggregation
                   death_mom(i_part,i_mom) = death_mom(i_part,i_mom)            &
                        + w(i_part,j1) * w(j_part,j2) * xi(i_part,j1)**i_mom    &
                        * part_beta_array(i_part,j_part,j1,j2) * 6.D0           &
                        / ( pi_g * diam_j_j2**3 * part_dens_array(j_part,j2) )

                   !WRITE(*,*) part_beta_array(i_part,i_part,j1,j2),             &
                   !     death_mom(i_part,i_mom)

                   ! death of nonOrg due to nonOrg-org aggregation
                   death_mom(j_part,i_mom) = death_mom(j_part,i_mom)            &
                        + w(j_part,j1) * w(i_part,j2) * xi(j_part,j1)**i_mom    &
                        * part_beta_array(j_part,i_part,j1,j2) * 6.D0           &
                        / ( pi_g * diam_i_j2**3 * part_dens_array(i_part,j2) )

                   ! death of nonOrg due to nonOrg-nonOrg aggregation
                   death_mom(j_part,i_mom) = death_mom(j_part,i_mom)            &
                        + w(j_part,j1) * w(j_part,j2) * xi(j_part,j1)**i_mom    &
                        * part_beta_array(j_part,j_part,j1,j2) * 6.D0           &
                        / ( pi_g * diam_j_j2**3 * part_dens_array(j_part,j2) )

                   ! birth of nonOrg due to org-org aggregation
                   birth_mom(j_part,i_mom) = birth_mom(j_part,i_mom)            &
                        + 0.5D0 * w(i_part,j1) * w(i_part,j2)                   &
                        * part_beta_array(i_part,i_part,j1,j2) * 6.D0 / pi_g    &
                        * ( part_dens_array(i_part,j1) * diam_i_j1**3           &
                        + part_dens_array(i_part,j2) * diam_i_j2**3 )           &
                        / ( part_dens_array(i_part,j1) * diam_i_j1**3           &
                        * part_dens_array(i_part,j2) * diam_i_j2**3 )           &
                        * ( - log( 2.D0** ( - 3.D0 * xi(i_part,j1) )            &
                        +  2.D0** ( - 3.D0 * xi(i_part,j2) ) ) / ( 3.D0         &
                        * log(2.D0) ) ) ** i_mom

                   ! birth of nonOrg due to nonOrg-nonOrg aggregation
                   birth_mom(j_part,i_mom) = birth_mom(j_part,i_mom)            &
                        + 0.5D0 * w(j_part,j1) * w(j_part,j2)                   &
                        * part_beta_array(j_part,j_part,j1,j2) * 6.D0 / pi_g    &
                        * ( part_dens_array(j_part,j1) * diam_j_j1**3           &
                        + part_dens_array(j_part,j2) * diam_j_j2**3 )           &
                        / ( part_dens_array(j_part,j1) * diam_j_j1**3           &
                        * part_dens_array(j_part,j2) * diam_j_j2**3 )           &
                        * ( - log( 2.D0** ( - 3.D0 * xi(j_part,j1) )            &
                        +  2.D0** ( - 3.D0 * xi(j_part,j2) ) ) / ( 3.D0         &
                        * log(2.D0) ) ) ** i_mom


                   ! birth of nonOrg due to org-nonOrg aggregation
                   birth_mom(j_part,i_mom) = birth_mom(j_part,i_mom)            &
                        + w(i_part,j1) * w(j_part,j2)                           &
                        * part_beta_array(i_part,j_part,j1,j2) * 6.D0 / pi_g    &
                        * ( part_dens_array(i_part,j1) * diam_i_j1**3           &
                        + part_dens_array(j_part,j2) * diam_j_j2**3 )           &
                        / ( part_dens_array(i_part,j1) * diam_i_j1**3           &
                        * part_dens_array(j_part,j2) * diam_j_j2**3 )           &
                        * ( - log( 2.D0** ( - 3.D0 * xi(i_part,j1) )            &
                        +  2.D0** ( - 3.D0 * xi(j_part,j2) ) ) / ( 3.D0         &
                        * log(2.D0) ) ) ** i_mom

                END DO

             END DO

             IF ( verbose_level .GE. 2 ) THEN

                WRITE(*,*) 'i_part,i_mom',i_part,i_mom

                WRITE(*,*) 'birth',i_part,i_mom,birth_mom(i_part,i_mom)
                WRITE(*,*) 'death',i_part,i_mom,death_mom(i_part,i_mom)
                WRITE(*,*) 'sum  ',i_part,i_mom,death_mom(i_part,i_mom)-birth_mom(i_part,i_mom)
                WRITE(*,*) 'birth',j_part,i_mom,birth_mom(j_part,i_mom)
                WRITE(*,*) 'death',j_part,i_mom,death_mom(j_part,i_mom)
                WRITE(*,*) 'sum  ',j_part,i_mom,death_mom(j_part,i_mom)-birth_mom(j_part,i_mom)
                READ(*,*)

             END IF

          END DO mom_loop


       END IF

    END DO


    RETURN

  END SUBROUTINE eval_aggregation_moments

  
END MODULE particles_module


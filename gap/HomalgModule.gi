#
# M2: Intrinsic modules with relations and generators for the CAP based homalg
#
# Implementations


####################################
#
# methods for operations:
#
####################################

##
InstallMethod( HomalgCategory,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],

  CapCategory );

##
InstallMethod( HomalgRing,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],

  function( M )
    
    if not IsBound( M!.ring ) then
        M!.ring := UnderlyingHomalgRing( RelationsOfModule( M ) );
    fi;
    
    return M!.ring;
    
end );

##
InstallMethod( ListOfPositionsOfKnownSetsOfRelations,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],

  function( M )
    
    return [ 1 .. PositionOfLastStoredCell( M ) ];

end );

##
InstallMethod( PositionOfTheDefaultSetOfGenerators,
        "for a homalg/CAP module",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject ],

  PositionOfActiveCell );

##
InstallMethod( SetPositionOfTheDefaultPresentation,
        "for a homalg/CAP module and an integer",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject, IsPosInt ],

  SetPositionOfActiveCell );

##
InstallMethod( HasNrGenerators,
        "for a homalg/CAP module",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject ],

  function( M )
    
    return HasNrGenerators( RelationsOfModule( M ) );
    
end );

##
InstallMethod( NrGenerators,
        "for a homalg/CAP module",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject ],

  function( M )
    local g;
    
    g := NrGenerators( RelationsOfModule( M ) );
    
    ## TODO: cleanup legacy code
    if g = 0 then
        SetIsZero( M, true );
    elif IsFinitelyPresentedModuleOrSubmoduleRep( M ) and
      HasRankOfObject( M ) and RankOfObject( M ) = g then
        SetIsFree( M, true );
    fi;
    
    return g;
    
end );

##
InstallMethod( GeneratorsOfModule,
        "for a homalg/CAP module",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject, IsPosInt ],
        
  function( M, pos )
    local gens;
    
    if pos > PositionOfLastStoredCell( M ) then
        return fail;
    fi;
    
    gens := EmbeddingInAmbientObject( CertainCell( M, pos ) );
    
    HomalgGeneratorsForModule( gens );
    
    return gens;
    
end );

##
InstallMethod( RelationsOfModule,
        "for a homalg/CAP module and a positive integer",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject, IsPosInt ],
        
  function( M, pos )
    local rels;
    
    if pos > PositionOfLastStoredCell( M ) then
        return fail;
    fi;
    
    rels := ObjectWithoutAmbientObject( CertainCell( M, pos ) );
    
    rels := HomalgRelationsForModule( rels );
    
    INSTALL_TODO_LIST_ENTRIES_FOR_RELATIONS_OF_MODULES( rels, M );
    
    return rels;
    
end );

##
InstallMethod( MatrixOfRelations,
        "for a homalg/CAP module",
        [ IsHomalgModule and IsCapCategoryIntrinsicObject ],
        
  function( M )
    
    return MatrixOfRelations( RelationsOfModule( M ) );
    
end );

##
InstallMethod( DecideZero,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],
        
  function( M )
    local gens;
    
    gens := GeneratorsOfModule( M );
    
    IsZero( gens );
    
    return gens;
    
end );

##
InstallMethod( BasisOfModule,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],
        
  function( M )
    local rels;
    
    ApplyFunctor( CapCategory( M )!.IdSM, M );
    
    rels := RelationsOfModule( M );
    
    INSTALL_TODO_LIST_ENTRIES_FOR_MATRICES_OF_RELATIONS( MatrixOfRelations( rels ), rels );
    
    return rels;
    
end );

##
InstallMethod( OnLessGenerators,
        "for a homalg/CAP module",
        [ IsFinitelyPresentedModuleRep and IsCapCategoryIntrinsicObject ],
        
  function( M )
    
    return ApplyFunctor( CapCategory( M )!.IdLG, M );
    
end );

####################################
#
# methods for constructors:
#
####################################

##
InstallMethod( CategoryOfHomalgLeftModules,
        "for a homalg ring",
        [ IsHomalgRing ],

  function( R )
    local A, SM, etaSM, LG, etaLG, Id, type_obj, type_mor, IdSM, IdLG;
    
    A := LeftPresentations( R );
    
    SM := FunctorStandardModuleLeft( R );
    
    etaSM := NaturalIsomorphismFromIdentityToStandardModuleLeft( R );
    
    LG := FunctorLessGeneratorsLeft( R );
    
    etaLG := NaturalIsomorphismFromIdentityToLessGeneratorsLeft( R );
    
    ## CategoryWithAmbientObject
    
    A := CategoryWithAmbientObject( A );
    
    Id := IdentityFunctor( A );
    
    SM := WithAmbientObject( SM, A );
    
    etaSM := WithAmbientObject( etaSM, Id, SM );
    
    LG := WithAmbientObject( LG, A );
    
    etaLG := WithAmbientObject( etaLG, Id, LG );
    
    type_obj :=
      NewType( TheFamilyOfIntrinsicObjects,
              IsCapCategoryIntrinsicObjectRep and
              IsFinitelyPresentedModuleRep and
              IsHomalgLeftObjectOrMorphismOfLeftObjects
              );
    
    type_mor :=
      NewType( TheFamilyOfIntrinsicMorphisms,
              IsCapCategoryIntrinsicMorphismRep and
              IsMapOfFinitelyGeneratedModulesRep and
              IsHomalgLeftObjectOrMorphismOfLeftObjects
              );
    
    ## IntrinsicCategory
    
    A := IntrinsicCategory( A, type_obj, type_mor );
    
    ## TODO: legacy
    SetFilterObj( A, IsHomalgCategory );
    A!.containers := rec( );
    
    Id := IdentityFunctor( A );
    
    SM := Intrinsify( SM, A );
    
    etaSM := Intrinsify( etaSM, Id, SM );
    
    LG := Intrinsify( LG, A );
    
    etaLG := Intrinsify( etaLG, Id, LG );
    
    ## TurnAutoequivalenceIntoIdentityFunctor
    
    IdSM := TurnAutoequivalenceIntoIdentityFunctor( etaSM );
    
    A!.IdSM := IdSM;
    
    IdLG := TurnAutoequivalenceIntoIdentityFunctor( etaLG );
    
    A!.IdLG := IdLG;
    
    return A;
    
end );

##
InstallMethod( CategoryOfHomalgRightModules,
        "for homalg ring",
        [ IsHomalgRing ],

  function( R )
    local A, SM, etaSM, LG, etaLG, Id, type_obj, type_mor, IdSM, IdLG;
    
    A := RightPresentations( R );
    
    SM := FunctorStandardModuleRight( R );
    
    etaSM := NaturalIsomorphismFromIdentityToStandardModuleRight( R );
    
    LG := FunctorLessGeneratorsRight( R );
    
    etaLG := NaturalIsomorphismFromIdentityToLessGeneratorsRight( R );
    
    ## CategoryWithAmbientObject
    
    A := CategoryWithAmbientObject( A );
    
    Id := IdentityFunctor( A );
    
    SM := WithAmbientObject( SM, A );
    
    etaSM := WithAmbientObject( etaSM, Id, SM );
    
    LG := WithAmbientObject( LG, A );
    
    etaLG := WithAmbientObject( etaLG, Id, LG );
    
    type_obj :=
      NewType( TheFamilyOfIntrinsicObjects,
              IsCapCategoryIntrinsicObjectRep and
              IsFinitelyPresentedModuleRep and
              IsHomalgRightObjectOrMorphismOfRightObjects
              );
    
    type_mor :=
      NewType( TheFamilyOfIntrinsicMorphisms,
              IsCapCategoryIntrinsicMorphismRep and
              IsMapOfFinitelyGeneratedModulesRep and
              IsHomalgRightObjectOrMorphismOfRightObjects
              );
    
    ## IntrinsicCategory
    
    A := IntrinsicCategory( A, type_obj, type_mor );
    
    ## TODO: legacy
    SetFilterObj( A, IsHomalgCategory );
    A!.containers := rec( );
    
    Id := IdentityFunctor( A );
    
    SM := Intrinsify( SM, A );
    
    etaSM := Intrinsify( etaSM, Id, SM );
    
    LG := Intrinsify( LG, A );
    
    etaLG := Intrinsify( etaLG, Id, LG );
    
    ## TurnAutoequivalenceIntoIdentityFunctor
    
    IdSM := TurnAutoequivalenceIntoIdentityFunctor( etaSM );
    
    A!.IdSM := IdSM;
    
    IdLG := TurnAutoequivalenceIntoIdentityFunctor( etaLG );
    
    A!.IdLG := IdLG;
    
    return A;
    
end );

##
InstallMethod( Intrinsify,
        "for a CAP intrinsic category and an object with ambient object",
        [ IsCapCategory, IsCapCategoryObjectWithAmbientObject ],

  function( A, cell )
    local left, rels, M;
    
    rels := ObjectWithoutAmbientObject( cell );
    
    HomalgRelationsForModule( rels );
    
    M := Intrinsify( A, cell, A!.TheTypeIntrinsicObject );
    
    M!.string := "module";
    M!.string_plural := "modules";
    M!.PresentationMorphisms := rec( );
    M!.Resolutions := rec( );
    
    return M;
    
end );

##
InstallMethod( HomalgModule,
        "for a left or right CAP presentation",
        [ IsLeftOrRightPresentation ],

  function( M )
    local A, left, R, pi, iota;
    
    A := CapCategory( M );
    
    left := IsLeftPresentation( M );
    
    R := UnderlyingHomalgRing( M );
    
    A := CategoryWithAmbientObject( A );
    
    pi := AsGeneralizedMorphismByCospan( CoverByFreeModule( M ) );
    
    iota := PseudoInverse( pi );
    
    M := ObjectWithAmbientObject( iota, A );
    
    if left then
        A := CategoryOfHomalgLeftModules( R );
    else
        A := CategoryOfHomalgRightModules( R );
    fi;
    
    M := Intrinsify( A, M );
    
    return M;
    
end );

##
InstallMethod( LeftPresentation,
        "for a homalg matrix",
        [ IsHomalgMatrix ],

  function( M )
    
    M := AsLeftPresentation( M );
    
    return HomalgModule( M );
    
end );

##
InstallMethod( RightPresentation,
        "constructor for homalg right modules",
        [ IsHomalgMatrix ],

  function( M )
    
    M := AsRightPresentation( M );
    
    return HomalgModule( M );
    
end );

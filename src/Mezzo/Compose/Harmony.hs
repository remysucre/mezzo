{-# LANGUAGE TypeInType, TypeApplications, TemplateHaskell, RankNTypes,
    GADTs, ImplicitParams, FlexibleContexts, TypeOperators #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Mezzo.Compose.Harmony
-- Description :  Harmony composition units
-- Copyright   :  (c) Dima Szamozvancev
-- License     :  MIT
--
-- Maintainer  :  ds709@cam.ac.uk
-- Stability   :  experimental
-- Portability :  portable
--
-- Literals for chords and progressions.
--
-----------------------------------------------------------------------------

module Mezzo.Compose.Harmony where

import Mezzo.Model
import Mezzo.Compose.Types
import Mezzo.Compose.Builder
import Mezzo.Compose.Templates
import Mezzo.Compose.Basic

import GHC.TypeLits

infixr 5 :+

-- * Time signatures

-- | Duple meter (2/4).
duple :: TimeSig 2
duple = TimeSig

-- | Triple meter (3/4).
triple :: TimeSig 3
triple = TimeSig

-- | Quadruple meter (4/4).
quadruple :: TimeSig 4
quadruple = TimeSig

-- * Functional harmony

-- ** Progressions

-- | Create a new musical progression from the given time signature and progression schema.
prog :: ProgConstraints t p => TimeSig t -> Prog p -> Music (FromProg p t)
prog = Progression

-- ** Phrases

type InKey k v = KeyS k -> v

-- | List of phrases in a progression parameterised by the key, ending with a cadence.
data PhraseList (p :: ProgType k l) where
    Cdza :: Cad c -> KeyS k -> PhraseList (CadPhrase c)
    (:+) :: InKey k (Phr p) -> InKey k (PhraseList ps) -> KeyS k -> PhraseList (p := ps)

-- | Specify the key of a progression.
inKey :: KeyS k -> InKey k (PhraseList p) -> Prog p
inKey k p = Prog

-- | Create a new cadential phrase.
cadence :: InKey k (Cad c) -> InKey k (PhraseList (CadPhrase c))
cadence c = \k -> Cdza (c k) k

-- | Dominant-tonic phrase.
ph_VI :: InKey k (Dom (d :: Dominant k l1)) -> InKey k (Ton (t :: Tonic k (l - l1))) -> InKey k (Phr (PhraseVI d t :: Phrase k l))
ph_VI _ _ = const Phr

-- | Tonic-dominant-tonic phrase.
ph_IVI :: InKey k (Ton (t1 :: Tonic k (l2 - l1))) -> InKey k (Dom (d :: Dominant k l1)) -> InKey k (Ton (t2 :: Tonic k (l - l2))) -> InKey k (Phr (PhraseIVI t1 d t2 :: Phrase k l))
ph_IVI _ _ _ = const Phr

-- ** Cadences

-- | Authentic V-I dominant cadence.
auth_V :: InKey k (Cad (AuthCad (DegChord :: DegreeC V MajQ k Inv1 Oct2) (DegChord :: DegreeC I (KeyToQual k) k Inv0 Oct3)))
auth_V = const Cad

-- | Authentic V7-I dominant seventh cadence.
auth_V7 :: InKey k (Cad (AuthCad7 (DegChord :: DegreeC V DomQ k Inv2 Oct2) (DegChord :: DegreeC I (KeyToQual k) k Inv0 Oct3)))
auth_V7 = const Cad

-- | Authentic vii-I leading tone cadence.
auth_vii :: InKey k (Cad (AuthCadVii (DegChord :: DegreeC VII DimQ k Inv1 Oct2) (DegChord :: DegreeC I (KeyToQual k) k Inv0 Oct3)))
auth_vii = const Cad

-- | Authentic cadential 6-4 cadence.
auth_64 :: InKey k (Cad (AuthCad64 (DegChord :: DegreeC I (KeyToQual k) k Inv2 Oct3) (DegChord :: DegreeC V DomQ k Inv3 Oct2) (DegChord :: DegreeC I (KeyToQual k) k Inv1 Oct3)))
auth_64 = const Cad

decept :: InKey k (Cad (DeceptCad (DegChord :: DegreeC V DomQ k Inv2 Oct2) (DegChord :: DegreeC VI (KeyToOtherQual k) k Inv1 Oct2)))
decept = const Cad

full :: InKey k (Sub s) -> InKey k (Cad c) -> InKey k (Cad (FullCad s c))
full _ _ = const Cad

-- ** Tonic chords

-- | Major tonic chord.
ton :: InKey k (Ton ('Tonic (DegChord :: DegreeC I (KeyToQual k) k Inv0 Oct3)))
ton = const Ton

-- | Minor tonic chord.
-- ton_min :: IsMinor k => InKey k (Ton (TonMin (DegChord :: DegreeC I MinQ k Inv0 Oct3)))
-- ton_min = const Ton

-- ** Dominants

-- | Dominant (V) chord.
dom_V :: InKey k (Dom (DomVM (DegChord :: DegreeC V MajQ k Inv2 Oct2)))
dom_V = const Dom

-- | Dominant seventh (V7) chord.
dom_V7 :: InKey k (Dom (DomV7 (DegChord :: DegreeC V DomQ k Inv2 Oct2)))
dom_V7 = const Dom

-- | Dominant leading tone (vii) chord.
dom_vii0 :: InKey k (Dom (DomVii0 (DegChord :: DegreeC VII DimQ k Inv1 Oct2)))
dom_vii0 = const Dom

-- | Secondary dominant - dominant (V/V-V7) chord.
dom_ii_V7 :: InKey k (Dom (DomSecD (DegChord :: DegreeC II DomQ k Inv0 Oct3) (DegChord :: DegreeC V DomQ k Inv2 Oct2)))
dom_ii_V7 = const Dom

-- | Subdominant followed by a dominant.
dom_SD :: InKey k (Sub subdom) -> InKey k (Dom dom) -> InKey k (Dom (DomSD subdom dom))
dom_SD _ _ = const Dom

-- ** Subdominants

-- | Subdominant minor second (ii) chord.
subdom_IV :: InKey k (Sub (SubIV (DegChord :: DegreeC IV (KeyToQual k) k Inv2 Oct2)))
subdom_IV = const Sub

-- | Subdominant minor second (ii) chord.
subdom_ii :: IsMajor k => InKey k (Sub (SubIIm (DegChord :: DegreeC II MinQ k Inv0 Oct3)))
subdom_ii = const Sub

-- | Subdominant minor second (ii) chord.
subdom_iii_IV :: IsMajor k => InKey k (Sub (SubIIImIVM (DegChord :: DegreeC III MinQ k Inv0 Oct3) (DegChord :: DegreeC IV MajQ k Inv3 Oct2)))
subdom_iii_IV = const Sub


-- * Key literals

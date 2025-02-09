open Core_kernel
open Kimchi_pasta_snarky_backend.Intf

module type Inputs_intf = sig
  module Verifier_index : T0

  module Field : sig
    type t
  end

  module Proof : sig
    type t

    type with_public_evals

    module Challenge_polynomial : T0

    module Backend : sig
      type t

      type with_public_evals
    end

    val to_backend :
      Challenge_polynomial.t list -> Field.t list -> t -> Backend.t

    val to_backend_with_public_evals :
         Challenge_polynomial.t list
      -> Field.t list
      -> with_public_evals
      -> Backend.with_public_evals
  end

  module Backend : sig
    type t = Field.t Kimchi_types.oracles

    val create : Verifier_index.t -> Proof.Backend.t -> t

    val create_with_public_evals :
      Verifier_index.t -> Proof.Backend.with_public_evals -> t
  end
end

module Make (Inputs : Inputs_intf) = struct
  open Inputs

  let create vk prev_challenge input (pi : Proof.t) =
    let pi = Proof.to_backend prev_challenge input pi in
    Backend.create vk pi

  let create_with_public_evals vk prev_challenge input
      (pi : Proof.with_public_evals) =
    let pi = Proof.to_backend_with_public_evals prev_challenge input pi in
    Backend.create_with_public_evals vk pi

  open Backend

  let scalar_challenge t = Scalar_challenge.create t

  let alpha (t : t) = t.o.alpha_chal

  let beta (t : t) = t.o.beta

  let gamma (t : t) = t.o.gamma

  let zeta (t : t) = t.o.zeta_chal

  let joint_combiner_chal (t : t) = Option.map ~f:fst t.o.joint_combiner

  let joint_combiner (t : t) = Option.map ~f:snd t.o.joint_combiner

  let digest_before_evaluations (t : t) = t.digest_before_evaluations

  let v (t : t) = t.o.v_chal

  let u (t : t) = t.o.u_chal

  let p_eval_1 (t : t) = fst t.p_eval

  let p_eval_2 (t : t) = snd t.p_eval

  let opening_prechallenges (t : t) =
    Array.map ~f:scalar_challenge t.opening_prechallenges
end

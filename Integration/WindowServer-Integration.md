# WindowServer integration

The current implementation and patch instructions are in [HostPatch/README.md](HostPatch/README.md).

Use `Tools/apply_nyxian_patch.py` against a clean Nyxian source checkout. Do not patch the signed IPA or compiled Procursus ROM directly. The script validates the expected WindowServer insertion point and refuses to patch an unfamiliar source version.

The supplied Beta is identified as 0.11.5, build `20261014.2.RELEASE`. A successful build and runtime test are still required before installing a modified app.

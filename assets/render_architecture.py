# /// script
# requires-python = ">=3.11"
# dependencies = ["matplotlib"]
# ///
"""Render the movie-review-platform architecture diagram to assets/architecture.png.

Run:  uv run assets/render_architecture.py

Reproduces the ASCII diagram that previously lived in README.org, laid out as
two side-by-side lanes (CI on the left, CD on the right) feeding a wide GKE
cluster container, with Firestore and the monitoring stack beneath it.

Content / ordering is identical to the original ASCII:

  CI lane  Developers -> GitHub Repo -> CI Pipeline
           -> Test and lint app code -> Build Docker Image -> GCR (Artifact Reg.)
  CD lane  (GCR --pull request triggers CD--> ) CD Pipeline (Terraform/Helm)
           -> Terraform: Deploys Cloud Infrastructure
           -> Bash Test Script Validation --Testing-->
              Helm/ArgoCD: Deploy Manifests in GKE
  Cluster  GKE Cluster w/ ArgoCD
             Deployment --> HPA
             Deployment v   HPA v
             Service <--> Ingress
             Service v
             Pods
             (ArgoCD watches Git repo)
  Data/Obs GCP NoSQL Firestore DB
           Monitoring Stack on GKE (Prometheus / Grafana Alloy Agent / Loki)
"""
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

# Box fill colours by role
C = {
    "entry":    "#D6EAF8",  # Developers (external actor)
    "git":      "#D5DBDB",  # GitHub Repo
    "ci":       "#D5F5E3",  # CI pipeline steps (green = go)
    "registry": "#FCF3CF",  # GCR / Artifact Registry
    "cd":       "#FDEBD0",  # CD pipeline steps
    "iac":      "#FADBD8",  # Terraform (infrastructure)
    "test":     "#E8DAEF",  # Bash test validation
    "cluster":  "#D1F2EB",  # GKE cluster container
    "k8s":      "#EAECEE",  # in-cluster Kubernetes objects
    "db":       "#D6EAF8",  # Firestore
    "obs":      "#E8DAEF",  # monitoring stack
}

fig, ax = plt.subplots(figsize=(12, 15.2))
ax.set_xlim(0, 16)
ax.set_ylim(0.4, 20.6)
ax.axis("off")


def box(cx, cy, w, h, title, subtitle, color, title_size=9.5, sub_size=7.5,
        ec="#566573", lw=1.2, rounded=0.02):
    ax.add_patch(FancyBboxPatch(
        (cx - w / 2, cy - h / 2), w, h,
        boxstyle=f"round,pad=0.02,rounding_size={rounded}",
        fc=color, ec=ec, lw=lw))
    ax.text(cx, cy + h * 0.16, title, ha="center", va="center",
            fontsize=title_size, fontweight="bold", color="#1B2631")
    if subtitle:
        ax.text(cx, cy - h * 0.22, subtitle, ha="center", va="center",
                fontsize=sub_size, color="#444")


def arrow(x1, y1, x2, y2, label=None, style="-", color="#34495E",
          rad=0.0, loff=(0, 0.16), lw=1.4):
    ax.add_patch(FancyArrowPatch(
        (x1, y1), (x2, y2), arrowstyle="-|>", mutation_scale=13,
        connectionstyle=f"arc3,rad={rad}", lw=lw, color=color,
        linestyle=style, shrinkA=2, shrinkB=2))
    if label:
        mx, my = (x1 + x2) / 2 + loff[0], (y1 + y2) / 2 + loff[1]
        ax.text(mx, my, label, ha="center", va="center", fontsize=7.3,
                color="#515A5A", style="italic",
                bbox=dict(boxstyle="round,pad=0.15", fc="white", ec="none",
                          alpha=0.85))


# ---------------------------------------------------------------------------
# CI lane (left, cx = 4)
# ---------------------------------------------------------------------------
ci_x = 4.0
box(ci_x, 18.8, 3.6, 0.85, "Developers", "push code", C["entry"])
box(ci_x, 17.5, 3.6, 0.85, "GitHub Repo", "source of truth", C["git"])
box(ci_x, 16.2, 3.6, 0.85, "CI Pipeline", "GitHub Actions", C["ci"])
box(ci_x, 14.9, 3.6, 0.85, "Test & lint app code", "jest · eslint · prettier", C["ci"])
box(ci_x, 13.6, 3.6, 0.85, "Build Docker Image", "multi-arch build", C["ci"])
box(ci_x, 12.3, 3.6, 0.85, "GCR (Artifact Reg.)", "ghcr.io image tag", C["registry"])

arrow(ci_x, 18.375, ci_x, 17.925, label="git push")
arrow(ci_x, 17.075, ci_x, 16.625, label="triggers")
arrow(ci_x, 15.775, ci_x, 15.325)
arrow(ci_x, 14.475, ci_x, 14.025)
arrow(ci_x, 13.175, ci_x, 12.725, label="push")

# ---------------------------------------------------------------------------
# CD lane (right, cx = 12)  -- top aligns with GCR
# ---------------------------------------------------------------------------
cd_x = 12.0
box(cd_x, 12.3, 3.8, 0.85, "CD Pipeline", "Terraform / Helm", C["cd"])
box(cd_x, 11.0, 3.8, 0.85, "Terraform", "deploys cloud infrastructure", C["iac"])
box(cd_x, 9.7, 3.8, 0.85, "Bash Test Script", "validates tf outputs", C["test"])
box(cd_x, 8.4, 3.8, 0.85, "Helm / ArgoCD", "deploy manifests in GKE", C["cd"])

# GCR -> CD Pipeline (the lane hand-off)
arrow(5.8, 12.3, 10.1, 12.3,
      label="pull request triggers CD pipeline", color="#7E5109")

arrow(cd_x, 11.875, cd_x, 11.425)
arrow(cd_x, 10.575, cd_x, 10.125)
arrow(cd_x, 9.275, cd_x, 8.825, label="Testing")

# ---------------------------------------------------------------------------
# GKE cluster container
# ---------------------------------------------------------------------------
CL_X0, CL_X1, CL_Y0, CL_Y1 = 1.0, 15.0, 3.2, 6.9
ax.add_patch(FancyBboxPatch(
    (CL_X0, CL_Y0), CL_X1 - CL_X0, CL_Y1 - CL_Y0,
    boxstyle="round,pad=0.02,rounding_size=0.06",
    fc=C["cluster"], ec="#148F77", lw=1.8))
ax.text((CL_X0 + CL_X1) / 2, CL_Y1 - 0.28, "GKE Cluster  ·  ArgoCD-managed",
        ha="center", va="center", fontsize=11, fontweight="bold",
        color="#0B5345")

# CD -> cluster
arrow(cd_x, 7.975, cd_x, CL_Y1, label="deploys")

# In-cluster Kubernetes objects
box(4.0, 5.75, 2.4, 0.7, "Deployment", "movie-api", C["k8s"],
    title_size=8.5, sub_size=6.8)
box(8.0, 5.75, 2.4, 0.7, "HPA", "Horizontal Pod Autoscaler", C["k8s"],
    title_size=8.5, sub_size=6.8)
box(4.0, 4.55, 2.4, 0.7, "Service", "ClusterIP / LB", C["k8s"],
    title_size=8.5, sub_size=6.8)
box(8.0, 4.55, 2.4, 0.7, "Ingress", "external entry", C["k8s"],
    title_size=8.5, sub_size=6.8)
box(4.0, 3.6, 2.4, 0.62, "Pods", "stateless app replicas", C["k8s"],
    title_size=8.5, sub_size=6.8)

# Cluster-internal relationships (mirror the ASCII)
arrow(5.2, 5.75, 6.8, 5.75)                      # Deployment --> HPA
arrow(4.0, 5.4, 4.0, 4.9)                        # Deployment v Service
arrow(8.0, 5.4, 8.0, 4.9)                        # HPA v Ingress
arrow(5.2, 4.55, 6.8, 4.55)                      # Service --> Ingress
arrow(6.8, 4.55, 5.2, 4.55, color="#7F8C8D")     # Ingress --> Service (bidir)
arrow(4.0, 4.2, 4.0, 3.91)                       # Service v Pods

# ArgoCD watches-git annotation (faithful to the ASCII's inline note)
ax.text(12.3, 5.2, "ArgoCD", ha="center", va="center", fontsize=9,
        fontweight="bold", color="#0B5345")
ax.text(12.3, 4.75, "watches Git repo", ha="center", va="center",
        fontsize=7.8, color="#0B5345", style="italic")
ax.text(12.3, 4.3, "(self-heal · sync)", ha="center", va="center",
        fontsize=7.0, color="#515A5A", style="italic")

# ---------------------------------------------------------------------------
# Data + observability beneath the cluster
# ---------------------------------------------------------------------------
box(5.0, 1.7, 4.4, 1.0, "GCP NoSQL Firestore DB", "fully managed · persists across pod restarts",
    C["db"], title_size=9.5, sub_size=7.2)
box(11.5, 1.7, 5.6, 1.0, "Monitoring Stack on GKE", "Prometheus · Grafana Alloy Agent · Loki",
    C["obs"], title_size=9.5, sub_size=7.2)

arrow(5.0, CL_Y0, 5.0, 2.2, label="reads / writes")
arrow(11.5, CL_Y0, 11.5, 2.2, label="scrapes / collects", color="#7D3C98")

# ---------------------------------------------------------------------------
# Title + caption
# ---------------------------------------------------------------------------
ax.text(8, 20.2, "Cloud-Native Movie Review Platform — CI/CD & Runtime Architecture",
        ha="center", va="center", fontsize=13.5, fontweight="bold")
ax.text(8, 19.7,
        "git push triggers CI  ·  CI builds & pushes the image  ·  "
        "CD provisions infra (Terraform) and syncs manifests (ArgoCD) into GKE",
        ha="center", va="center", fontsize=8.2, color="#666", style="italic")

plt.tight_layout()
out = Path(__file__).parent / "architecture.png"
plt.savefig(out, dpi=150, bbox_inches="tight")
print(f"saved {out}  ({out.stat().st_size:,} bytes)")

import csv
import os
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROGRAMS = sorted((ROOT / "real-tests").glob("*.lox"))
PLOX_PROJECT = Path(
    os.environ.get("PLOX_PROJECT", ROOT.parent / "plox-fede")
).resolve()
COMMAND = ["uv", "run", "--offline", "--no-sync", "--project", str(PLOX_PROJECT), "plox"]
RESULTS = Path(__file__).resolve().parent / "results_python.csv"
REPETITIONS = 10
WARMUPS = 2

if not PROGRAMS:
    raise SystemExit("No se encontraron archivos .lox en real-tests/")
if not (PLOX_PROJECT / "pyproject.toml").is_file():
    raise SystemExit(f"No se encontró el proyecto Plox: {PLOX_PROJECT}")


def measure(program):
    start = time.perf_counter()
    result = subprocess.run(
        [*COMMAND, str(program)],
        stdin=subprocess.DEVNULL,
        capture_output=True,
        text=True,
        timeout=60,
        check=False,
    )
    elapsed = time.perf_counter() - start

    if (
        result.returncode != 0
        or result.stderr
        or "OK" not in result.stdout.splitlines()
        or "error" in result.stdout.lower()
    ):
        raise RuntimeError(
            f"Falló {program.name}: stdout={result.stdout!r}, "
            f"stderr={result.stderr!r}, exit={result.returncode}"
        )

    return elapsed


samples = {}

for program in PROGRAMS:
    for _ in range(WARMUPS):
        measure(program)
    samples[program.name] = [measure(program) for _ in range(REPETITIONS)]

RESULTS.parent.mkdir(parents=True, exist_ok=True)
with RESULTS.open("w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["implementation", "benchmark", "iteration", "seconds"])
    for benchmark, times in samples.items():
        for iteration, seconds in enumerate(times, start=1):
            writer.writerow(["python", benchmark, iteration, seconds])

    writer.writerow([])
    writer.writerow([
        "implementation", "benchmark", "minimum_seconds", "mean_seconds", "maximum_seconds"
    ])
    for benchmark, times in samples.items():
        writer.writerow([
            "python", benchmark, min(times), statistics.mean(times), max(times)
        ])

print(f"Resultados guardados en {RESULTS}")

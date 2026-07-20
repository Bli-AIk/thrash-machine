#!/usr/bin/env python3
import argparse
import re
import zipfile
from pathlib import Path


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def replace_once(text: str, pattern: str, replacement: str, path: Path, flags: int = 0) -> str:
    patched, count = re.subn(pattern, replacement, text, count=1, flags=flags)
    if count != 1:
        raise SystemExit(f"Could not patch {pattern!r} in {path}")
    return patched


def lua_quote(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def patch_lua_config(args: argparse.Namespace) -> None:
    stage_dir = Path(args.stage_dir)
    vendcust = stage_dir / "src" / "engine" / "vendcust.lua"
    conf = stage_dir / "conf.lua"

    text = read_text(vendcust)
    for pattern, replacement in {
        r"(?m)^TARGET_MOD\s*=.*$": f"TARGET_MOD = {lua_quote(args.mod_id)}",
        r"(?m)^AUTO_MOD_START\s*=.*$": "AUTO_MOD_START = true",
        r"(?m)^RELEASE_MODE\s*=.*$": f"RELEASE_MODE = {args.release_mode}",
    }.items():
        text = replace_once(text, pattern, replacement, vendcust)
    write_text(vendcust, text)

    text = read_text(conf)
    text = replace_once(
        text,
        r"(?m)^(\s*t\.identity\s*=\s*).*$",
        rf"\g<1>{lua_quote(args.identity)}",
        conf,
    )
    text = replace_once(
        text,
        r"(?m)^(\s*t\.window\.title\s*=\s*).*$",
        rf"\g<1>{lua_quote(args.title)}",
        conf,
    )
    write_text(conf, text)


def patch_mod_manifest(args: argparse.Namespace) -> None:
    manifest = Path(args.manifest)
    text = read_text(manifest)
    text = replace_once(text, r'("dev"\s*:\s*)(true|false)', rf"\g<1>{args.dev}", manifest)
    text = replace_once(
        text,
        r'("object-editor"\s*:\s*\{.*?"enabled"\s*:\s*)(true|false)',
        rf"\g<1>{args.object_editor}",
        manifest,
        flags=re.S,
    )
    write_text(manifest, text)


def zip_dir(args: argparse.Namespace) -> None:
    output = Path(args.output)
    source = Path(args.source)
    prefix = args.prefix.strip("/")
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sorted(source.rglob("*")):
            if path.is_file():
                relative = path.relative_to(source).as_posix()
                archive.write(path, f"{prefix}/{relative}" if prefix else relative)


def main() -> None:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)

    patch_lua = commands.add_parser("patch-lua-config")
    patch_lua.add_argument("stage_dir")
    patch_lua.add_argument("mod_id")
    patch_lua.add_argument("release_mode", choices=("true", "false"))
    patch_lua.add_argument("identity")
    patch_lua.add_argument("title")
    patch_lua.set_defaults(handler=patch_lua_config)

    patch_manifest = commands.add_parser("patch-mod-manifest")
    patch_manifest.add_argument("manifest")
    patch_manifest.add_argument("dev", choices=("true", "false"))
    patch_manifest.add_argument("object_editor", choices=("true", "false"))
    patch_manifest.set_defaults(handler=patch_mod_manifest)

    zip_command = commands.add_parser("zip-dir")
    zip_command.add_argument("output")
    zip_command.add_argument("source")
    zip_command.add_argument("prefix", nargs="?", default="")
    zip_command.set_defaults(handler=zip_dir)

    args = parser.parse_args()
    args.handler(args)


if __name__ == "__main__":
    main()

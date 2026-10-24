output "env_config_paths" {
  description = "File paths of generated environment configs keyed by environment name"
  value       = { for k, v in local_file.env_configs : k => v.filename }
}

output "scratch_note_files" {
  description = "List of all scratch note files created using count"
  value       = local_file.scratch_notes[*].filename
}

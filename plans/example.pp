plan snow_record::example(
  TargetSpec $nodes,
  ) {
  # Create an incident   
  $r1 = run_task(snow_record::create_incident, $nodes,'Create an incident',
  'urgency'         => '1',
  'priority'        => '2',
  'severity'        => '3',
  'additional_data' => '{"short_description":"This is a test incident opened by Puppet"}')
  $incident_number = $r1.map |$r| { $r["result"]["number"] }

  # Get the incident's sys_id   
  $r2 = run_task(snow_record::read, $nodes,'Get the incident sys_id',
    'number' => $incident_number[0]
  )
  $val = $r2.map |$r| { $r["result"][0]["sys_id"] }
  $sys_id = $val[0]

  # Update the incident's description 
  $r3 = run_task(snow_record::update, $nodes,'Resolve the incident',
  'sys_id' => $sys_id,
  'data'   => '{"description":"This is a longer description about the test incident opened by Puppet"}')

  # Resolve the incident    
  $r4 = run_task(snow_record::resolve_incident, $nodes,'Resolve the incident',
  'sys_id'          => $sys_id,
  'close_notes'     => 'It is closing time.',
  'additional_data' => '{"close_code":"Solved (Work Around)"}')

  out::message("Incident URL: https://${nodes}.service-now.com/task.do?sys_id=${sys_id}")
}

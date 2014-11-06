$affinity = 3

$Processes = Get-Process *server
foreach($Process in $Processes)
{
	$Process.PriorityClass = "RealTime"
	$Process.ProcessorAffinity = $affinity
	switch ($affinity)
	{
		3 { $affinity = 12 }
		12 { $affinity = 48 }
		48 { $affinity = 192 }
	}
}
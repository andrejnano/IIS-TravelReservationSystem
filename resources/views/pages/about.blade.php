@extends('layouts.app')

@section('content')
    <h1>ABOUT</h1>
    <p>abouttttt</p>
    <div class="grid">
    <table>

    <?php
    $results = DB::select('select * FROM flights', [1]);
    // dd($results);
    
    echo "<tr>\n";
    foreach($results[0] as $key=>$value) {
        echo "<th>".$key."</th>\n";
    }
    echo "</tr>\n";
    foreach($results as $r){
        // echo "result".$r;
        echo "<tr>\n";
        foreach($r as $key=>$value) {
            echo "<td>".$value."</td>\n";
        }
        echo "</tr>\n";
    }
    ?>
    </table>
    </div>
@endsection
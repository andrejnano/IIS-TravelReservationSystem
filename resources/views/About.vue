<template>
  <v-content>
    <v-container fluid>
      <v-layout row justify-center>
        <v-flex xs11 sm9 md8 lg6 pa-4 ma-4>
          <v-card>
            <v-card-title class="headline"><span class='mdi mdi-information-outline'/>&nbsp;&nbsp;About</v-card-title>
            <v-card-text>
              <p>
                The application is divided into to main parts, frontend and backend. We have used this division so the 
                two parts could be implemented simultaneously without conflicts. One student can implement frontend and 
                other backend without conflicts and everybody can do what suits him better. Between this two main parts 
                is application interface API, which was defined at the beginning of the project. API consists of 
                multiple definitions of routes and their usages and return values. Frontend can access resources from 
                backend using two types of requests GET or POST. Backend returns JSON containing information from the 
                database as response. Frontend then parses JSON and shows information to user.
              </p>
              <p>
                For implementation we have used two frameworks, Laravel for backend php implementation and Vue for 
                frontend javascript implementation. With this frameworks we have been able to create more user friendly application and simple things were automated by the framework.
              </p>
            </v-card-text>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>
  </v-content>

</template>

<script>
export default {
}
</script>

<style>

</style>
